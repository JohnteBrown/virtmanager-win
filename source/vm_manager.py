"""QEMU VM inventory and lifecycle operations for the QtQuick interface."""

from __future__ import annotations

import json
import re
import shutil
import sys
from pathlib import Path

from PySide6.QtCore import (
    QObject,
    Property,
    QProcess,
    QStandardPaths,
    QTimer,
    Signal,
    Slot,
)


class VMManager(QObject):
    """Manage qcow2 disks and QEMU processes owned by this application."""

    vmsChanged = Signal()
    messageChanged = Signal()
    operationError = Signal(str)

    _name_pattern = re.compile(r"^[A-Za-z0-9][A-Za-z0-9 _-]{0,47}$")

    def __init__(self, parent: QObject | None = None) -> None:
        super().__init__(parent)
        data_directory = QStandardPaths.writableLocation(
            QStandardPaths.StandardLocation.AppDataLocation
        )
        self._vm_directory = Path(data_directory) / "vms"
        self._vm_directory.mkdir(parents=True, exist_ok=True)
        self._processes: dict[str, QProcess] = {}
        self._states: dict[str, str] = {}
        self._pending_creations: dict[str, tuple[QProcess, tuple[int, int, int]]] = {}
        self._message = ""

    @Property(list, notify=vmsChanged)
    def vms(self) -> list[dict[str, object]]:
        """Return the managed disk inventory in a QML-friendly format."""
        inventory = []
        for disk_path in sorted(self._vm_directory.glob("*.qcow2")):
            metadata = self._read_metadata(disk_path)
            inventory.append(
                {
                    "name": disk_path.stem,
                    "state": self._states.get(disk_path.stem, "Stopped"),
                    "memoryMb": self._metadata_int(metadata, "memory_mb", 2048),
                    "cpus": self._metadata_int(metadata, "cpus", 2),
                    "diskSizeGb": self._metadata_int(metadata, "disk_size_gb", 10),
                }
            )
        return inventory

    @Property(str, notify=messageChanged)
    def message(self) -> str:
        return self._message

    @Slot()
    def refresh(self) -> None:
        self.vmsChanged.emit()

    @Slot(str, int, int, int, result=bool)
    def createVm(
        self, name: str, memory_mb: int, cpus: int, disk_size_gb: int
    ) -> bool:
        name = name.strip()
        if not self._name_pattern.fullmatch(name):
            return self._fail(
                "Use a name starting with a letter or number; only letters, "
                "numbers, spaces, hyphens, and underscores are allowed (48 characters max)."
            )
        if not 512 <= memory_mb <= 131072:
            return self._fail("Memory must be between 512 and 131072 MB.")
        if not 1 <= cpus <= 64:
            return self._fail("CPU count must be between 1 and 64.")
        if not 1 <= disk_size_gb <= 4096:
            return self._fail("Disk size must be between 1 and 4096 GB.")

        disk_path = self._disk_path(name)
        if disk_path.exists() or name in self._pending_creations:
            return self._fail(f'A VM named "{name}" already exists.')

        qemu_img = self._find_program("qemu-img")
        if qemu_img is None:
            return self._fail(
                "qemu-img was not found. Install QEMU and add its bin folder to PATH."
            )

        process = QProcess(self)
        process.setProgram(qemu_img)
        process.setArguments(
            ["create", "-f", "qcow2", str(disk_path), f"{disk_size_gb}G"]
        )
        process.finished.connect(
            lambda exit_code, _status, vm_name=name: self._creation_finished(
                vm_name, exit_code
            )
        )
        process.errorOccurred.connect(
            lambda error, vm_name=name: self._creation_error(vm_name, error)
        )
        self._pending_creations[name] = (
            process,
            (memory_mb, cpus, disk_size_gb),
        )
        self._set_message(f'Creating "{name}"...')
        process.start()
        return True

    @Slot(str, result=bool)
    def startVm(self, name: str) -> bool:
        disk_path = self._disk_path(name)
        if not disk_path.is_file():
            return self._fail(f'VM disk for "{name}" was not found.')
        existing_process = self._processes.get(name)
        if (
            existing_process
            and existing_process.state() != QProcess.ProcessState.NotRunning
        ):
            return self._fail(f'"{name}" is already running or starting.')

        qemu_system = self._find_program("qemu-system-x86_64")
        if qemu_system is None:
            return self._fail(
                "qemu-system-x86_64 was not found. Install QEMU and add its "
                "bin folder to PATH."
            )

        metadata = self._read_metadata(disk_path)
        memory_mb = self._metadata_int(metadata, "memory_mb", 2048)
        cpus = self._metadata_int(metadata, "cpus", 2)
        process = QProcess(self)
        process.setProgram(qemu_system)
        process.setArguments(
            [
                "-machine",
                "q35",
                "-drive",
                f"file={disk_path},format=qcow2",
                "-m",
                str(memory_mb),
                "-smp",
                str(cpus),
            ]
        )
        process.started.connect(lambda vm_name=name: self._process_started(vm_name))
        process.finished.connect(
            lambda exit_code, _status, vm_name=name: self._process_finished(
                vm_name, exit_code, process
            )
        )
        process.errorOccurred.connect(
            lambda error, vm_name=name: self._process_error(vm_name, error, process)
        )
        self._processes[name] = process
        self._states[name] = "Starting"
        self.vmsChanged.emit()
        self._set_message(f'Starting "{name}"...')
        process.start()
        return True

    @Slot(str, result=bool)
    def stopVm(self, name: str) -> bool:
        process = self._processes.get(name)
        if process is None or process.state() == QProcess.ProcessState.NotRunning:
            return self._fail(f'"{name}" is not running in this application.')

        self._states[name] = "Stopping"
        self.vmsChanged.emit()
        self._set_message(f'Stopping "{name}"...')
        process.terminate()
        QTimer.singleShot(3000, lambda: self._kill_if_running(name, process))
        return True

    @Slot(str, result=bool)
    def deleteVm(self, name: str) -> bool:
        process = self._processes.get(name)
        if process and process.state() != QProcess.NotRunning:
            return self._fail("Stop the VM before deleting its disk.")

        disk_path = self._disk_path(name)
        if not disk_path.is_file():
            return self._fail(f'VM disk for "{name}" was not found.')
        try:
            disk_path.unlink()
            self._metadata_path(disk_path).unlink(missing_ok=True)
        except OSError as error:
            return self._fail(f"Could not delete the VM disk: {error}")

        self._processes.pop(name, None)
        self._states.pop(name, None)
        self.vmsChanged.emit()
        self._set_message(f'Deleted "{name}".')
        return True

    def _creation_finished(self, name: str, exit_code: int) -> None:
        pending = self._pending_creations.pop(name, None)
        if pending is None:
            return
        process, metadata = pending
        disk_path = self._disk_path(name)
        if exit_code != 0:
            details = (
                bytes(process.readAllStandardError())
                .decode("utf-8", errors="replace")
                .strip()
            )
            disk_path.unlink(missing_ok=True)
            message = details or f"qemu-img exited with code {exit_code}."
            self._set_error(f'Could not create "{name}": {message}')
        else:
            if not disk_path.is_file():
                self._set_error(
                    "qemu-img exited successfully but did not create the disk."
                )
            else:
                try:
                    self._create_metadata(disk_path, *metadata)
                except OSError as error:
                    self._set_error(
                        f"Created disk, but could not save VM settings: {error}"
                    )
                else:
                    self._set_message(f'Created "{name}".')
            self.vmsChanged.emit()
        process.deleteLater()

    def _creation_error(self, name: str, error: QProcess.ProcessError) -> None:
        if error != QProcess.ProcessError.FailedToStart:
            return
        pending = self._pending_creations.pop(name, None)
        if pending is None:
            return
        process, _metadata = pending
        process.deleteLater()
        self._disk_path(name).unlink(missing_ok=True)
        self._set_error(
            "Could not start qemu-img. Check the QEMU installation and PATH."
        )

    def _process_started(self, name: str) -> None:
        self._states[name] = "Running"
        self.vmsChanged.emit()
        self._set_message(f'"{name}" is running.')

    def _process_finished(self, name: str, exit_code: int, process: QProcess) -> None:
        if self._processes.get(name) is not process:
            process.deleteLater()
            return
        self._processes.pop(name, None)
        self._states[name] = "Stopped"
        self.vmsChanged.emit()
        if exit_code:
            details = ""
            if process is not None:
                details = (
                    bytes(process.readAllStandardError())
                    .decode("utf-8", errors="replace")
                    .strip()
                )
            self._set_error(details or f'"{name}" exited with code {exit_code}.')
        else:
            self._set_message(f'"{name}" stopped.')
        if process is not None:
            process.deleteLater()

    def _process_error(
        self, name: str, error: QProcess.ProcessError, process: QProcess
    ) -> None:
        if error != QProcess.ProcessError.FailedToStart:
            return
        if self._processes.get(name) is not process:
            return
        self._processes.pop(name, None)
        self._states[name] = "Stopped"
        self.vmsChanged.emit()
        self._set_error("Could not start QEMU. Check the installation and VM settings.")
        process.deleteLater()

    def _kill_if_running(self, name: str, process: QProcess) -> None:
        if (
            self._processes.get(name) is process
            and process.state() != QProcess.ProcessState.NotRunning
        ):
            process.kill()

    def _find_program(self, program: str) -> str | None:
        names = [f"{program}.exe", program] if sys.platform == "win32" else [program]
        for name in names:
            resolved = shutil.which(name)
            if resolved:
                return resolved
        return None

    def _disk_path(self, name: str) -> Path:
        if not self._name_pattern.fullmatch(name):
            raise ValueError("Invalid VM name")
        return self._vm_directory / f"{name}.qcow2"

    @staticmethod
    def _metadata_path(disk_path: Path) -> Path:
        return disk_path.with_suffix(".json")

    def _read_metadata(self, disk_path: Path) -> dict[str, object]:
        try:
            metadata = json.loads(
                self._metadata_path(disk_path).read_text(encoding="utf-8")
            )
        except (OSError, json.JSONDecodeError):
            return {}
        return metadata if isinstance(metadata, dict) else {}

    def _create_metadata(
        self, disk_path: Path, memory_mb: int, cpus: int, disk_size_gb: int
    ) -> None:
        metadata = {
            "memory_mb": memory_mb,
            "cpus": cpus,
            "disk_size_gb": disk_size_gb,
        }
        self._metadata_path(disk_path).write_text(
            json.dumps(metadata, indent=2) + "\n", encoding="utf-8"
        )

    @staticmethod
    def _metadata_int(metadata: dict[str, object], key: str, default: int) -> int:
        try:
            return int(metadata.get(key, default))
        except (TypeError, ValueError):
            return default

    def _fail(self, message: str) -> bool:
        self._set_error(message)
        return False

    def _set_error(self, message: str) -> None:
        self._set_message(message)
        self.operationError.emit(message)

    def _set_message(self, message: str) -> None:
        self._message = message
        self.messageChanged.emit()
