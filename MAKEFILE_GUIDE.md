# Makefile Quick Reference Guide

This guide provides a quick overview of all available Makefile targets for the `virtmanager-win` project.

## 🚀 Quick Start

```bash
make help          # Show all available commands
make install       # Install dependencies
make build         # Build Cython extensions
make test          # Run tests
make run           # Start the application
```

## 📋 All Available Targets

### Environment Setup
| Command | Description |
|---------|-------------|
| `make install` | Install dependencies using uv |
| `make install-pip` | Install dependencies using pip (fallback) |
| `make install-dev` | Install development dependencies |
| `make venv` | Create virtual environment |

### Cython Build System
| Command | Description |
|---------|-------------|
| `make build` | Build Cython extensions |
| `make build-force` | Force rebuild of Cython extensions |
| `make build-debug` | Build with debug symbols |
| `make cython-annotate` | Generate HTML annotations for optimization |

### Testing
| Command | Description |
|---------|-------------|
| `make test` | Run all tests including Cython tests |
| `make test-cython` | Run only Cython extension tests |
| `make test-unit` | Run unit tests with pytest |
| `make test-coverage` | Run tests with coverage report |

### Code Quality
| Command | Description |
|---------|-------------|
| `make format` | Format code with black and isort |
| `make lint` | Lint code with flake8 |
| `make type-check` | Run type checking with mypy |
| `make check` | Run all code quality checks |

### Application
| Command | Description |
|---------|-------------|
| `make run` | Run the main application |
| `make run-dev` | Run application in development mode |
| `make debug` | Run application with debug build |

### Distribution
| Command | Description |
|---------|-------------|
| `make build-dist` | Build distribution packages |
| `make upload-test` | Upload to test PyPI |
| `make upload` | Upload to PyPI |

### Cleanup
| Command | Description |
|---------|-------------|
| `make clean` | Clean build artifacts and cache files |
| `make clean-all` | Clean everything including virtual environment |

### Development Tools
| Command | Description |
|---------|-------------|
| `make shell` | Open interactive Python shell with project in path |
| `make notebook` | Start Jupyter notebook server |
| `make deps-update` | Update dependencies |
| `make deps-graph` | Show dependency graph |

### Git Hooks
| Command | Description |
|---------|-------------|
| `make pre-commit` | Run pre-commit checks |
| `make install-hooks` | Install pre-commit git hooks |

### Project Info
| Command | Description |
|---------|-------------|
| `make info` | Show project information |

### Special Workflows
| Command | Description |
|---------|-------------|
| `make quick` | Quick build and test cycle |
| `make full` | Full development cycle (clean, install, build, test, lint) |
| `make ci` | Continuous integration tasks |

### Platform-Specific
| Command | Description |
|---------|-------------|
| `make windows-build` | Build using Windows batch script |
| `make unix-build` | Build using Unix shell script |

## 🔧 Common Workflows

### Initial Setup
```bash
make venv          # Create virtual environment
source .venv/bin/activate  # Activate it (Linux/macOS)
# or .venv\Scripts\activate  # Windows
make install       # Install dependencies
make build         # Build Cython extensions
```

### Development Cycle
```bash
make quick         # Quick build and test
# or
make full          # Complete cycle with cleanup
```

### Before Committing
```bash
make pre-commit    # Format, lint, and test
```

### Release Preparation
```bash
make clean
make full
make build-dist
```

## 🎯 Tips

- Run `make help` anytime to see available targets
- Use `make info` to check your project setup
- The Makefile uses colors for better readability
- Most targets have error handling and informative output
- Development dependencies are optional but recommended

## 🛠️ Customization

The Makefile is highly configurable. Key variables at the top:

- `PROJECT_NAME`: Project name for display
- `PYTHON`: Python command to use
- `SOURCE_DIRS`: Directories containing Python source code
- `CYTHON_DIR`: Directory containing .pyx files

Edit these variables in the Makefile to match your project structure.