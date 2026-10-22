[![Build status](https://ci.appveyor.com/api/projects/status/tjybstwhn70bc4ay?svg=true)](https://ci.appveyor.com/project/JohnteBrown/virtmanager-win)

# Introduction 👋
Welcome to virtmanager-win, this is a side project of mine where
the goal is to make a UI Frontend for QEMU on windows for VirtManager in Python\Cython
in QtQuick (QML) with PySide.
**This is a work in progress. The current interface provides a basic local VM inventory and lifecycle controls; advanced VM configuration and installer workflows are not implemented yet.**

## AI Usage Policy 🤖
due to this project being developed by a Solo Developer (me), AI usage is limited to the following:

- [✅] AI is used to generate code snippets and documentation.
- [✅] AI is used to port minor components (command syntax like PowerShell, Bash, etc.)
- [✅] AI is used to generate boilerplate & utilities (makefiles, scripts, etc)
- [🕒] AI (Agentic) integration is being planned to improve the speed & ease of development.
- [🚫] AI is not used to generate user interface designs or layouts.
- [🚫] AI is not used to generate test cases or automated testing.
- [🚫] AI is not used to fix or otherwise patch security vulnerabilities.

----
## installation | WIP 💿
> [ℹ️] Install steps will likely be provided at the very end of the projects in-dev phase.

### **Windows**
**this is how you install virtmanager-win on windows (this is a placeholder)**

### **Building from source**
**please refer to [building.md](docs/building.md) for instructions on how to build virtmanager-win from source.**

### **Running the application**
Install the Python dependencies, ensure `qemu-img` and `qemu-system-x86_64` are available on `PATH`, then run:

```bash
uv sync
uv run python main.py
```

The UI can open without QEMU installed, but VM operations require those QEMU programs. Creating a VM creates a blank qcow2 disk; it does not install a guest operating system. Managed VM disks are stored under the application-data directory in a `vms` folder. Running the UI does not require building the separate Cython examples.

----

## Project links & resources 📕
[Project Roadmap](https://meekoo459s-team.monday.com/boards/18335311576)

[GitHub](https://github.com/johntebrown/virtmanager-win)

[VirtManager Site (COMING SOON)](https://example.com)
