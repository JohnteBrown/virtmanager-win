# AGENTS.md - AI Agent Instructions for virtmanager-win

virtmanager-win is a UI Frontend for QEMU for Windows written in Python/Cython in QtQuick using QML and PySide6, virtmanager-win uses AI to compensate for rather beginner-level programming skills (using the technologies the project employs) and speed up development speed. the focus is making sure the project functions and looks good. ensuring code maintainability such as excessive commenting and unused blocks of code will come after the project is functional. 

## Tech Stack
- **Language**: Python (3.13.14)

- **Tests**: Pytest
- **Bundler**: Pyinstaller
- **Linting**: Flake8
- **Formatter**: Black
- **Dependencies manager**: poetry
- **GUI Toolkit**: QtQuick, PySide6, QML

## Quick Start & Basic Commands

> [!IMPORTANT]
> **please refer to [building.md](docs/building.md) for instructions on how to build virtmanager-win from source.**

```bash
make help          # Show all available commands
make install       # Install dependencies
make build         # Build Cython extensions
make test          # Run tests
make run           # Start the application
```