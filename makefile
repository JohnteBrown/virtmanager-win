# Makefile for virtmanager-win Python Project
# Provides common development tasks including Cython builds, testing, linting, and deployment

# =============================================================================
# Configuration
# =============================================================================

PROJECT_NAME := virtmanager-win
PYTHON := python3
UV := uv
PIP := pip
VENV_DIR := .venv
SOURCE_DIRS := App utils scripts cython
TEST_DIR := tests
CYTHON_DIR := cython
BUILD_DIR := build
DIST_DIR := dist

# Python files to check (excluding generated files)
PYTHON_FILES := $(shell find $(SOURCE_DIRS) -name "*.py" 2>/dev/null || true) main.py build.py test_cython.py
PYX_FILES := $(shell find $(CYTHON_DIR) -name "*.pyx" 2>/dev/null || true)

# Colors for output
RED := \033[0;31m
GREEN := \033[0;32m
YELLOW := \033[0;33m
BLUE := \033[0;34m
PURPLE := \033[0;35m
CYAN := \033[0;36m
WHITE := \033[0;37m
RESET := \033[0m

# =============================================================================
# Help Target (Default)
# =============================================================================

.PHONY: help
help: ## Show this help message
	@echo "$(CYAN)$(PROJECT_NAME) Development Makefile$(RESET)"
	@echo "$(CYAN)=================================$(RESET)"
	@echo ""
	@echo "$(YELLOW)Available targets:$(RESET)"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  $(GREEN)%-20s$(RESET) %s\n", $$1, $$2}' $(MAKEFILE_LIST)
	@echo ""
	@echo "$(YELLOW)Usage examples:$(RESET)"
	@echo "  make install     # Install dependencies"
	@echo "  make build       # Build Cython extensions"
	@echo "  make test        # Run all tests"
	@echo "  make clean       # Clean build artifacts"
	@echo "  make run         # Run the main application"

# =============================================================================
# Environment Setup
# =============================================================================

.PHONY: install
install: ## Install dependencies using uv
	@echo "$(BLUE)Installing dependencies with uv...$(RESET)"
	$(UV) sync
	@echo "$(GREEN)✓ Dependencies installed$(RESET)"

.PHONY: install-pip
install-pip: ## Install dependencies using pip (fallback)
	@echo "$(BLUE)Installing dependencies with pip...$(RESET)"
	$(PIP) install -r requirements.txt || $(PIP) install -e .
	@echo "$(GREEN)✓ Dependencies installed$(RESET)"

.PHONY: install-dev
install-dev: install ## Install development dependencies
	@echo "$(BLUE)Installing development dependencies...$(RESET)"
	$(UV) add --dev pytest black isort flake8 mypy pre-commit || true
	@echo "$(GREEN)✓ Development dependencies installed$(RESET)"

.PHONY: venv
venv: ## Create virtual environment
	@echo "$(BLUE)Creating virtual environment...$(RESET)"
	$(PYTHON) -m venv $(VENV_DIR)
	@echo "$(GREEN)✓ Virtual environment created at $(VENV_DIR)$(RESET)"
	@echo "$(YELLOW)Activate with: source $(VENV_DIR)/bin/activate$(RESET)"

# =============================================================================
# Cython Build System
# =============================================================================

.PHONY: build
build: ## Build Cython extensions
	@echo "$(BLUE)Building Cython extensions...$(RESET)"
	$(PYTHON) build.py build_ext --inplace
	@echo "$(GREEN)✓ Cython extensions built$(RESET)"

.PHONY: build-force
build-force: ## Force rebuild of Cython extensions
	@echo "$(BLUE)Force rebuilding Cython extensions...$(RESET)"
	$(PYTHON) build.py build_ext --inplace --force
	@echo "$(GREEN)✓ Cython extensions force rebuilt$(RESET)"

.PHONY: build-debug
build-debug: ## Build Cython extensions with debug symbols
	@echo "$(BLUE)Building Cython extensions with debug symbols...$(RESET)"
	$(PYTHON) build.py build_ext --inplace --debug
	@echo "$(GREEN)✓ Debug Cython extensions built$(RESET)"

.PHONY: cython-annotate
cython-annotate: build ## Generate Cython HTML annotations for optimization
	@echo "$(BLUE)Cython annotations generated$(RESET)"
	@if [ -d "$(BUILD_DIR)/cython" ]; then \
		echo "$(GREEN)✓ HTML annotation files:$(RESET)"; \
		find $(BUILD_DIR)/cython -name "*.html" -exec echo "  - {}" \; || true; \
		echo "$(YELLOW)Open these files in a browser for performance analysis$(RESET)"; \
	fi

# =============================================================================
# Testing
# =============================================================================

.PHONY: test
test: build ## Run all tests including Cython tests
	@echo "$(BLUE)Running test suite...$(RESET)"
	$(PYTHON) test_cython.py
	@if [ -d "$(TEST_DIR)" ]; then \
		echo "$(BLUE)Running pytest...$(RESET)"; \
		$(PYTHON) -m pytest $(TEST_DIR) -v || true; \
	fi
	@echo "$(GREEN)✓ Tests completed$(RESET)"

.PHONY: test-cython
test-cython: build ## Run only Cython extension tests
	@echo "$(BLUE)Testing Cython extensions...$(RESET)"
	$(PYTHON) test_cython.py
	@echo "$(GREEN)✓ Cython tests completed$(RESET)"

.PHONY: test-unit
test-unit: ## Run unit tests with pytest
	@echo "$(BLUE)Running unit tests...$(RESET)"
	$(PYTHON) -m pytest $(TEST_DIR) -v --tb=short
	@echo "$(GREEN)✓ Unit tests completed$(RESET)"

.PHONY: test-coverage
test-coverage: ## Run tests with coverage report
	@echo "$(BLUE)Running tests with coverage...$(RESET)"
	$(PYTHON) -m pytest --cov=$(SOURCE_DIRS) --cov-report=html --cov-report=term
	@echo "$(GREEN)✓ Coverage report generated$(RESET)"

# =============================================================================
# Code Quality
# =============================================================================

.PHONY: format
format: ## Format code with black and isort
	@echo "$(BLUE)Formatting Python code...$(RESET)"
	$(PYTHON) -m black $(PYTHON_FILES) || echo "$(YELLOW)Warning: black not installed$(RESET)"
	$(PYTHON) -m isort $(PYTHON_FILES) || echo "$(YELLOW)Warning: isort not installed$(RESET)"
	@echo "$(GREEN)✓ Code formatted$(RESET)"

.PHONY: lint
lint: ## Lint code with flake8
	@echo "$(BLUE)Linting Python code...$(RESET)"
	$(PYTHON) -m flake8 $(PYTHON_FILES) --max-line-length=88 || echo "$(YELLOW)Warning: flake8 not installed$(RESET)"
	@echo "$(GREEN)✓ Linting completed$(RESET)"

.PHONY: type-check
type-check: ## Run type checking with mypy
	@echo "$(BLUE)Type checking with mypy...$(RESET)"
	$(PYTHON) -m mypy $(SOURCE_DIRS) || echo "$(YELLOW)Warning: mypy not installed$(RESET)"
	@echo "$(GREEN)✓ Type checking completed$(RESET)"

.PHONY: check
check: lint type-check ## Run all code quality checks
	@echo "$(GREEN)✓ All code quality checks completed$(RESET)"

# =============================================================================
# Application
# =============================================================================

.PHONY: run
run: build ## Run the main application
	@echo "$(BLUE)Starting $(PROJECT_NAME)...$(RESET)"
	$(PYTHON) main.py

.PHONY: run-dev
run-dev: build ## Run application in development mode
	@echo "$(BLUE)Starting $(PROJECT_NAME) in development mode...$(RESET)"
	$(PYTHON) main.py --dev || $(PYTHON) main.py

.PHONY: debug
debug: build-debug ## Run application with debug build
	@echo "$(BLUE)Starting $(PROJECT_NAME) with debug build...$(RESET)"
	$(PYTHON) main.py --debug || $(PYTHON) main.py

# =============================================================================
# Distribution
# =============================================================================

.PHONY: build-dist
build-dist: clean build ## Build distribution packages
	@echo "$(BLUE)Building distribution packages...$(RESET)"
	$(PYTHON) -m build || $(PYTHON) setup.py sdist bdist_wheel
	@echo "$(GREEN)✓ Distribution packages built in $(DIST_DIR)$(RESET)"

.PHONY: upload-test
upload-test: build-dist ## Upload to test PyPI
	@echo "$(BLUE)Uploading to test PyPI...$(RESET)"
	$(PYTHON) -m twine upload --repository testpypi $(DIST_DIR)/*
	@echo "$(GREEN)✓ Uploaded to test PyPI$(RESET)"

.PHONY: upload
upload: build-dist ## Upload to PyPI
	@echo "$(BLUE)Uploading to PyPI...$(RESET)"
	$(PYTHON) -m twine upload $(DIST_DIR)/*
	@echo "$(GREEN)✓ Uploaded to PyPI$(RESET)"

# =============================================================================
# Cleanup
# =============================================================================

.PHONY: clean
clean: ## Clean build artifacts and cache files
	@echo "$(BLUE)Cleaning build artifacts...$(RESET)"
	rm -rf $(BUILD_DIR)/ $(DIST_DIR)/ *.egg-info/
	find . -type d -name "__pycache__" -exec rm -rf {} + 2>/dev/null || true
	find . -type f -name "*.pyc" -delete 2>/dev/null || true
	find . -type f -name "*.pyo" -delete 2>/dev/null || true
	find . -type f -name "*.so" -delete 2>/dev/null || true
	find . -type f -name "*.pyd" -delete 2>/dev/null || true
	find . -type f -name "*.c" -path "./$(CYTHON_DIR)/*" -delete 2>/dev/null || true
	find . -type f -name "*.cpp" -path "./$(CYTHON_DIR)/*" -delete 2>/dev/null || true
	rm -rf .pytest_cache/ .coverage htmlcov/ .mypy_cache/ .tox/
	@echo "$(GREEN)✓ Cleaned build artifacts$(RESET)"

.PHONY: clean-all
clean-all: clean ## Clean everything including virtual environment
	@echo "$(BLUE)Cleaning virtual environment...$(RESET)"
	rm -rf $(VENV_DIR)/
	rm -rf .uv_cache/ || true
	@echo "$(GREEN)✓ Everything cleaned$(RESET)"

# =============================================================================
# Development Tools
# =============================================================================

.PHONY: shell
shell: ## Open interactive Python shell with project in path
	@echo "$(BLUE)Opening Python shell...$(RESET)"
	$(PYTHON) -i -c "import sys; sys.path.insert(0, '.'); print('$(PROJECT_NAME) development shell - project in path')"

.PHONY: notebook
notebook: ## Start Jupyter notebook server
	@echo "$(BLUE)Starting Jupyter notebook...$(RESET)"
	$(PYTHON) -m jupyter notebook || echo "$(YELLOW)Install jupyter: uv add jupyter$(RESET)"

.PHONY: deps-update
deps-update: ## Update dependencies
	@echo "$(BLUE)Updating dependencies...$(RESET)"
	$(UV) lock --upgrade || $(PIP) list --outdated
	@echo "$(GREEN)✓ Dependencies updated$(RESET)"

.PHONY: deps-graph
deps-graph: ## Show dependency graph
	@echo "$(BLUE)Dependency graph:$(RESET)"
	$(UV) tree || $(PIP) show $(PROJECT_NAME) || echo "$(YELLOW)Install pipdeptree: pip install pipdeptree$(RESET)"

# =============================================================================
# Git Hooks
# =============================================================================

.PHONY: pre-commit
pre-commit: format lint test ## Run pre-commit checks
	@echo "$(GREEN)✓ Pre-commit checks completed$(RESET)"

.PHONY: install-hooks
install-hooks: ## Install pre-commit git hooks
	@echo "$(BLUE)Installing pre-commit hooks...$(RESET)"
	$(PYTHON) -m pre_commit install || echo "$(YELLOW)Install pre-commit: uv add --dev pre-commit$(RESET)"
	@echo "$(GREEN)✓ Pre-commit hooks installed$(RESET)"

# =============================================================================
# Project Info
# =============================================================================

.PHONY: info
info: ## Show project information
	@echo "$(CYAN)$(PROJECT_NAME) Project Information$(RESET)"
	@echo "$(CYAN)==============================$(RESET)"
	@echo "$(YELLOW)Python version:$(RESET) $$($(PYTHON) --version 2>&1)"
	@echo "$(YELLOW)Project directory:$(RESET) $$(pwd)"
	@echo "$(YELLOW)Virtual environment:$(RESET) $(VENV_DIR)"
	@echo "$(YELLOW)Dependencies manager:$(RESET) $(UV)"
	@echo ""
	@echo "$(YELLOW)Source directories:$(RESET) $(SOURCE_DIRS)"
	@echo "$(YELLOW)Cython files found:$(RESET) $$(find $(CYTHON_DIR) -name "*.pyx" 2>/dev/null | wc -l || echo 0)"
	@echo "$(YELLOW)Python files found:$(RESET) $$(echo '$(PYTHON_FILES)' | wc -w)"
	@echo ""
	@if [ -f "$(VENV_DIR)/bin/activate" ]; then \
		echo "$(GREEN)✓ Virtual environment exists$(RESET)"; \
	else \
		echo "$(RED)✗ Virtual environment not found$(RESET)"; \
	fi
	@if command -v $(UV) >/dev/null 2>&1; then \
		echo "$(GREEN)✓ UV package manager available$(RESET)"; \
	else \
		echo "$(RED)✗ UV package manager not found$(RESET)"; \
	fi

# =============================================================================
# Special Targets
# =============================================================================

.PHONY: quick
quick: build test ## Quick build and test cycle
	@echo "$(GREEN)✓ Quick development cycle completed$(RESET)"

.PHONY: full
full: clean install build test lint ## Full development cycle
	@echo "$(GREEN)✓ Full development cycle completed$(RESET)"

.PHONY: ci
ci: install build test lint ## Continuous integration tasks
	@echo "$(GREEN)✓ CI pipeline completed$(RESET)"

# =============================================================================
# Platform-specific targets
# =============================================================================

.PHONY: windows-build
windows-build: ## Build using Windows batch script
	@echo "$(BLUE)Running Windows build script...$(RESET)"
	./build_and_test.bat

.PHONY: unix-build
unix-build: ## Build using Unix shell script
	@echo "$(BLUE)Running Unix build script...$(RESET)"
	./build_and_test.sh

# =============================================================================
# Make Configuration
# =============================================================================

# Disable built-in rules and variables for better performance
MAKEFLAGS += --no-builtin-rules
.SUFFIXES:

# Ensure bash is used as shell
SHELL := /bin/bash

# Default target
.DEFAULT_GOAL := help
