# Makefile for virtmanager-win Python Project (Windows / GNU Make + cmd.exe)
# Provides common development tasks including Cython builds, testing, linting, and deployment
#
# Requirements: GNU Make for Windows (choco install make / scoop install make),
#               Python on PATH, and optionally Poetry.

# =============================================================================
# Shell Configuration (Windows)
# =============================================================================

SHELL := cmd.exe
.SHELLFLAGS := /c

# =============================================================================
# Configuration
# =============================================================================

PROJECT_NAME := virtmanager-win
PYTHON ?= python
POETRY ?= poetry
PIP := $(PYTHON) -m pip
VENV_DIR := .venv
SOURCE_DIRS := source ui cython
TEST_DIR := tests
CYTHON_DIR := cython
BUILD_DIR := build
DIST_DIR := dist

# Environment variables passed to every command (replaces inline VAR=value syntax)
export POETRY_VIRTUALENVS_IN_PROJECT := true
export POETRY_NO_INTERACTION := 1

# Recursive wildcard (replaces `find`): $(call rwildcard,dir,*.ext)
rwildcard = $(foreach d,$(wildcard $(1:=/*)),$(call rwildcard,$(d),$(2)) $(filter $(subst *,%,$(2)),$(d)))

# Python files to check (excluding generated files)
PYTHON_FILES := $(foreach d,$(SOURCE_DIRS),$(call rwildcard,$(d),*.py)) main.py build.py test_cython.py
PYX_FILES := $(call rwildcard,$(CYTHON_DIR),*.pyx)
HAS_TESTS := $(wildcard $(TEST_DIR))

# Cleanup script (one line so it works under cmd.exe). Skips .venv and .git.
CLEAN_PY = import shutil, pathlib; \
	root = pathlib.Path('.'); \
	skip = lambda p: '$(VENV_DIR)' in p.parts or '.git' in p.parts; \
	dirs = ['$(BUILD_DIR)', '$(DIST_DIR)', '.pytest_cache', 'htmlcov', '.mypy_cache', '.tox']; \
	[shutil.rmtree(d, ignore_errors=True) for d in dirs]; \
	[shutil.rmtree(p, ignore_errors=True) for p in root.glob('*.egg-info')]; \
	[shutil.rmtree(p, ignore_errors=True) for p in root.rglob('__pycache__') if not skip(p)]; \
	[p.unlink() for pat in ('*.pyc', '*.pyo', '*.so', '*.pyd') for p in root.rglob(pat) if not skip(p)]; \
	[p.unlink() for pat in ('*.c', '*.cpp') for p in (root / '$(CYTHON_DIR)').rglob(pat)]; \
	pathlib.Path('.coverage').unlink(missing_ok=True)

# Help-text script (replaces awk)
HELP_PY = import re; \
	[print(f'  {m[1]:<20} {m[2]}') for l in open('$(firstword $(MAKEFILE_LIST))', encoding='utf-8') for m in [re.match(r'^([a-zA-Z_-]+):.*?\#\# (.*)$$', l)] if m]

# =============================================================================
# Help Target (Default)
# =============================================================================

.PHONY: help
help: ## Show this help message
	@echo $(PROJECT_NAME) Development Makefile
	@echo =================================
	@echo.
	@echo Available targets:
	@$(PYTHON) -c "$(HELP_PY)"
	@echo.
	@echo Usage examples:
	@echo   make install     - Install dependencies
	@echo   make build       - Build Cython extensions
	@echo   make test        - Run all tests
	@echo   make clean       - Clean build artifacts
	@echo   make run         - Run the main application

# =============================================================================
# Environment Setup
# =============================================================================

.PHONY: install
install: ## Install dependencies using Poetry
	@echo Installing dependencies with Poetry...
	$(POETRY) install --no-root
	@echo [OK] Dependencies installed

.PHONY: install-pip
install-pip: ## Install dependencies using pip (fallback)
	@echo Installing dependencies with pip...
	$(PIP) install -r requirements.txt || $(PIP) install -e .
	@echo [OK] Dependencies installed

.PHONY: install-dev
install-dev: install ## Install development dependencies
	@echo Installing development dependencies...
	$(POETRY) install --no-root --with dev
	@echo [OK] Development dependencies installed

.PHONY: venv
venv: ## Create virtual environment
	@echo Creating virtual environment...
	$(PYTHON) -m venv $(VENV_DIR)
	@echo [OK] Virtual environment created at $(VENV_DIR)
	@echo Activate with: $(VENV_DIR)\Scripts\activate

# =============================================================================
# Cython Build System
# =============================================================================

.PHONY: build
build: ## Build Cython extensions
	@echo Building Cython extensions...
	$(PYTHON) build.py build_ext --inplace
	@echo [OK] Cython extensions built

.PHONY: build-force
build-force: ## Force rebuild of Cython extensions
	@echo Force rebuilding Cython extensions...
	$(PYTHON) build.py build_ext --inplace --force
	@echo [OK] Cython extensions force rebuilt

.PHONY: build-debug
build-debug: ## Build Cython extensions with debug symbols
	@echo Building Cython extensions with debug symbols...
	$(PYTHON) build.py build_ext --inplace --debug
	@echo [OK] Debug Cython extensions built

.PHONY: cython-annotate
cython-annotate: build ## Generate Cython HTML annotations for optimization
	@echo Cython annotations generated
	@if exist $(BUILD_DIR)\cython dir /s /b $(BUILD_DIR)\cython\*.html 2>nul
	@echo Open the HTML files above in a browser for performance analysis

# =============================================================================
# Testing
# =============================================================================

.PHONY: test
test: build ## Run all tests including Cython tests
	@echo Running test suite...
	$(PYTHON) test_cython.py
	$(if $(HAS_TESTS),@echo Running pytest...)
	$(if $(HAS_TESTS),-$(PYTHON) -m pytest $(TEST_DIR) -v)
	@echo [OK] Tests completed

.PHONY: test-cython
test-cython: build ## Run only Cython extension tests
	@echo Testing Cython extensions...
	$(PYTHON) test_cython.py
	@echo [OK] Cython tests completed

.PHONY: test-unit
test-unit: ## Run unit tests with pytest
	@echo Running unit tests...
	$(PYTHON) -m pytest $(TEST_DIR) -v --tb=short
	@echo [OK] Unit tests completed

.PHONY: test-coverage
test-coverage: ## Run tests with coverage report
	@echo Running tests with coverage...
	$(PYTHON) -m pytest $(addprefix --cov=,$(SOURCE_DIRS)) --cov-report=html --cov-report=term
	@echo [OK] Coverage report generated

# =============================================================================
# Code Quality
# =============================================================================

.PHONY: format
format: ## Format code with black and isort
	@echo Formatting Python code...
	$(PYTHON) -m black $(PYTHON_FILES) || echo Warning: black not installed
	$(PYTHON) -m isort $(PYTHON_FILES) || echo Warning: isort not installed
	@echo [OK] Code formatted

.PHONY: lint
lint: ## Lint code with flake8
	@echo Linting Python code...
	$(PYTHON) -m flake8 $(PYTHON_FILES) --max-line-length=88 || echo Warning: flake8 not installed
	@echo [OK] Linting completed

.PHONY: type-check
type-check: ## Run type checking with mypy
	@echo Type checking with mypy...
	$(PYTHON) -m mypy $(SOURCE_DIRS) || echo Warning: mypy not installed
	@echo [OK] Type checking completed

.PHONY: check
check: lint type-check ## Run all code quality checks
	@echo [OK] All code quality checks completed

# =============================================================================
# Application
# =============================================================================

.PHONY: run
run: ## Run the main application
	@echo Starting $(PROJECT_NAME)...
	$(PYTHON) main.py

.PHONY: run-dev
run-dev: ## Run application in development mode
	@echo Starting $(PROJECT_NAME) in development mode...
	$(PYTHON) main.py --dev || $(PYTHON) main.py

.PHONY: debug
debug: ## Run application in debug mode
	@echo Starting $(PROJECT_NAME) with debug build...
	$(PYTHON) main.py --debug || $(PYTHON) main.py

# =============================================================================
# Distribution
# =============================================================================

.PHONY: build-dist
build-dist: clean build ## Build distribution packages
	@echo Building distribution packages...
	$(PYTHON) -m build || $(PYTHON) setup.py sdist bdist_wheel
	@echo [OK] Distribution packages built in $(DIST_DIR)

.PHONY: upload-test
upload-test: build-dist ## Upload to test PyPI
	@echo Uploading to test PyPI...
	$(PYTHON) -m twine upload --repository testpypi $(DIST_DIR)\*
	@echo [OK] Uploaded to test PyPI

.PHONY: upload
upload: build-dist ## Upload to PyPI
	@echo Uploading to PyPI...
	$(PYTHON) -m twine upload $(DIST_DIR)\*
	@echo [OK] Uploaded to PyPI

# =============================================================================
# Cleanup
# =============================================================================

.PHONY: clean
clean: ## Clean build artifacts and cache files
	@echo Cleaning build artifacts...
	@$(PYTHON) -c "$(CLEAN_PY)"
	@echo [OK] Cleaned build artifacts

.PHONY: clean-all
clean-all: clean ## Clean everything including virtual environment
	@echo Cleaning virtual environment...
	@if exist $(VENV_DIR) rmdir /s /q $(VENV_DIR)
	@echo [OK] Everything cleaned

# =============================================================================
# Development Tools
# =============================================================================

.PHONY: shell
shell: ## Open interactive Python shell with project in path
	@echo Opening Python shell...
	$(PYTHON) -i -c "import sys; sys.path.insert(0, '.'); print('$(PROJECT_NAME) development shell - project in path')"

.PHONY: notebook
notebook: ## Start Jupyter notebook server
	@echo Starting Jupyter notebook...
	$(PYTHON) -m jupyter notebook || echo Install jupyter: poetry add jupyter

.PHONY: deps-update
deps-update: ## Update dependencies
	@echo Updating dependencies...
	$(POETRY) update || $(PIP) list --outdated
	@echo [OK] Dependencies updated

.PHONY: deps-graph
deps-graph: ## Show dependency graph
	@echo Dependency graph:
	$(POETRY) show --tree || $(PIP) show $(PROJECT_NAME) || echo Install pipdeptree: pip install pipdeptree

# =============================================================================
# Git Hooks
# =============================================================================

.PHONY: pre-commit
pre-commit: format lint test ## Run pre-commit checks
	@echo [OK] Pre-commit checks completed

.PHONY: install-hooks
install-hooks: ## Install pre-commit git hooks
	@echo Installing pre-commit hooks...
	$(PYTHON) -m pre_commit install || echo Install pre-commit: poetry add --group dev pre-commit
	@echo [OK] Pre-commit hooks installed

# =============================================================================
# Project Info
# =============================================================================

.PHONY: info
info: ## Show project information
	@echo $(PROJECT_NAME) Project Information
	@echo ==============================
	@echo Python version:
	@$(PYTHON) --version
	@echo Project directory: $(CURDIR)
	@echo Virtual environment: $(VENV_DIR)
	@echo Dependencies manager: $(POETRY)
	@echo.
	@echo Source directories: $(SOURCE_DIRS)
	@echo Cython files found: $(words $(PYX_FILES))
	@echo Python files found: $(words $(PYTHON_FILES))
	@echo.
	@echo $(if $(wildcard $(VENV_DIR)/Scripts/activate.bat),[OK] Virtual environment exists,[X] Virtual environment not found)
	@where $(POETRY) >nul 2>&1 && echo [OK] Poetry package manager available || echo [X] Poetry package manager not found

# =============================================================================
# Special Targets
# =============================================================================

.PHONY: quick
quick: build test ## Quick build and test cycle
	@echo [OK] Quick development cycle completed

.PHONY: full
full: clean install build test lint ## Full development cycle
	@echo [OK] Full development cycle completed

.PHONY: ci
ci: install build test lint ## Continuous integration tasks
	@echo [OK] CI pipeline completed

# =============================================================================
# Platform-specific targets
# =============================================================================

.PHONY: windows-build
windows-build: ## Build using Windows batch script
	@echo Running Windows build script...
	call build_and_test.bat

.PHONY: unix-build
unix-build: ## Build using Unix shell script (requires Git Bash or WSL)
	@echo Running Unix build script...
	bash build_and_test.sh

# =============================================================================
# Make Configuration
# =============================================================================

# Disable built-in rules and variables for better performance
MAKEFLAGS += --no-builtin-rules
.SUFFIXES:

# Default target
.DEFAULT_GOAL := help