import sys
from pathlib import Path

from PySide6.QtCore import QCoreApplication, QUrl
from PySide6.QtGui import QGuiApplication
from PySide6.QtQml import QQmlApplicationEngine

from source.vm_manager import VMManager


def main():
    """Main application entry point."""
    QCoreApplication.setOrganizationName("VirtManager-Win")
    QCoreApplication.setApplicationName("VirtManager-Win")
    app = QGuiApplication(sys.argv)
    engine = QQmlApplicationEngine()

    base_dir = Path(__file__).resolve().parent
    qml_file = base_dir / "ui" / "Main.qml"

    if not qml_file.is_file():
        print(f"Error: QML file not found: {qml_file}", file=sys.stderr)
        return 1

    manager = VMManager()
    engine.rootContext().setContextProperty("vmManager", manager)
    engine.load(QUrl.fromLocalFile(str(qml_file)))

    if not engine.rootObjects():
        print("Error: Failed to load QML file", file=sys.stderr)
        return 1

    # Log application startup.
    log_file = base_dir / "log" / "main.log"
    try:
        log_file.parent.mkdir(parents=True, exist_ok=True)
        with log_file.open("a", encoding="utf-8") as log:
            log.write("Program started successfully.\n")
    except OSError as error:
        print(f"Warning: Could not write startup log: {error}", file=sys.stderr)

    return app.exec()


if __name__ == "__main__":
    sys.exit(main())
