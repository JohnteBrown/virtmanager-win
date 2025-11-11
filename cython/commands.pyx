# cython: language_level=3

import subprocess
import cython
import os
import sys
import sqlite3
import json
# imports

# static variables
VM_NAME = "new_vm"
VM_DISK_SIZE = "10G"
VM_MEMORY_SIZE = "2G"

def new_vm():
    # First create the disk image
    subprocess.run(["qemu-img", "create", "-f", "qcow2", f"{VM_NAME}.qcow2", VM_DISK_SIZE])
    # Then start the VM
    subprocess.run(["qemu-system-x86_64", "-machine", "pc", "-drive", f"file={VM_NAME}.qcow2,format=qcow2", "-m", VM_MEMORY_SIZE, "-smp", "2"])

def start_vm():
    subprocess.run(["qemu-system-x86_64", "-machine", "pc", "-drive", f"file={VM_NAME}.qcow2,format=qcow2", "-m", VM_MEMORY_SIZE, "-smp", "2"])

def stop_vm():
    # QEMU doesn't have a direct stop command, this would need to use monitor commands or kill the process
    subprocess.run(["pkill", "-f", f"{VM_NAME}.qcow2"])

def restart_vm():
    # Stop then start
    stop_vm()
    start_vm()

def delete_vm():
    # Remove the disk image file
    subprocess.run(["rm", f"{VM_NAME}.qcow2"])

def list_vms():
    # List qcow2 files in current directory
    subprocess.run(["ls", "-la", "*.qcow2"])

def update_vm():
    # This would typically involve updating the guest OS, no direct QEMU command
    subprocess.run(["qemu-system-x86_64", "-machine", "pc", "-drive", f"file={VM_NAME}.qcow2,format=qcow2", "-m", VM_MEMORY_SIZE, "-smp", "2"])

def backup_vm():
    # Copy the qcow2 file
    subprocess.run(["cp", f"{VM_NAME}.qcow2", f"{VM_NAME}_backup.qcow2"])

def restore_vm():
    # Restore from backup
    subprocess.run(["cp", f"{VM_NAME}_backup.qcow2", f"{VM_NAME}.qcow2"])
