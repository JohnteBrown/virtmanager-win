# CircleCI Configuration for virtmanager-win

This directory contains CircleCI configuration files for automated building and testing of the virtmanager-win project.

## Configuration Files

### `config.yml` (Main Configuration)
The primary CircleCI configuration with comprehensive features:
- **Multi-job workflow** with build, test, and code quality checks
- **Multi-platform testing** (Linux)
- **Python version compatibility** testing
- **Cython extension building** and testing
- **Code quality checks** (formatting, linting, type checking)
- **Scheduled nightly builds**
- **Artifact storage** for build outputs and Cython annotations

### `config-simple.yml` (Simplified Configuration)
A streamlined version for basic CI/CD needs:
- Single job that builds and tests
- Minimal setup with essential steps only
- Good starting point for simpler workflows

## Project Requirements

This CI configuration is designed for a Python project with:
- **Python 3.11+** (uses 3.12 in CI due to 3.14 availability)
- **Cython extensions** that need compilation
- **uv package manager** for dependency management
- **PySide6, NumPy, Cython** as main dependencies

## Setup Instructions

### 1. Choose Configuration
- Use `config.yml` for comprehensive CI/CD with multiple jobs
- Use `config-simple.yml` for basic build and test only

### 2. Activate Configuration
Rename your chosen config file to `config.yml`:
```bash
# For comprehensive setup (default)
# config.yml is already active

# For simple setup
mv config.yml config-full.yml
mv config-simple.yml config.yml
```

### 3. Connect Repository
1. Go to [CircleCI](https://circleci.com/)
2. Sign up/login with your GitHub account
3. Add your repository to CircleCI
4. The CI will automatically trigger on commits

## Workflow Details

### Main Workflow (`build_and_test_workflow`)
Runs on every commit:
- **build_and_test**: Main job that builds Cython extensions and runs tests
- **code_quality**: Runs formatting, linting, and type checking (after build succeeds)

### Comprehensive Workflow (`comprehensive_test`)
Runs on main branches and tags:
- **build_and_test**: Primary build and test
- **build_linux**: Platform-specific Linux build
- **test_python_311**: Tests with Python 3.11 compatibility
- **code_quality**: Code quality checks

### Nightly Workflow
Scheduled daily at 2 AM UTC for main branches:
- Full build and test cycle
- Helps catch dependency issues early

## Jobs Breakdown

### `build_and_test`
Main job that:
1. **Installs uv** package manager
2. **Installs dependencies** using `uv sync`
3. **Builds Cython extensions** using `build.py`
4. **Runs tests** including `test_cython.py`
5. **Stores artifacts** (build files, HTML annotations)

### `code_quality`
Code quality job that:
1. Installs development dependencies
2. Runs **black** for code formatting checks
3. Runs **isort** for import sorting checks
4. Runs **flake8** for linting

### `build_linux`
Platform-specific job that:
1. Builds on Linux environment
2. Provides platform-specific build information
3. Tests cross-platform compatibility

### `test_python_311`
Compatibility testing job that:
1. Tests with Python 3.11 instead of 3.12
2. Temporarily modifies `pyproject.toml` for compatibility
3. Ensures broader Python version support

## Environment Variables

You can set these in CircleCI project settings:

### Optional Variables
- `PYTHON_VERSION`: Override Python version (default: 3.12)
- `UV_CACHE_DIR`: Custom uv cache directory
- `BUILD_PARALLEL_JOBS`: Number of parallel build jobs

## Artifacts

The CI stores several artifacts:
- **build-artifacts**: Complete build directory
- **cython-annotations**: HTML files for Cython performance analysis

Access artifacts from:
- CircleCI web interface → Job → Artifacts tab
- Download links in job output

## Troubleshooting

### Common Issues

**1. Cython Build Failures**
```yaml
# Add debugging to build step
- run:
    name: Debug Cython build
    command: |
      python build.py build_ext --inplace --verbose
      ls -la cython/ virtmanager_cython/
```

**2. Python Version Issues**
The project requires Python 3.14, but CI uses 3.12. This is handled by:
- Using compatible Python 3.12 in CI
- Testing compatibility with 3.11 in separate job
- Temporarily modifying `pyproject.toml` for testing

**3. Dependency Installation Issues**
```yaml
# Add dependency debugging
- run:
    name: Debug dependencies
    command: |
      uv --version
      uv tree
      python -c "import cython; print('Cython:', cython.__version__)"
```

**4. Test Failures**
```yaml
# Add test debugging
- run:
    name: Debug tests
    command: |
      python -c "import sys; print('Python path:', sys.path)"
      find . -name "*.so" -ls
      python test_cython.py --verbose
```

### Performance Optimization

**1. Caching Dependencies**
```yaml
- restore_cache:
    keys:
      - uv-deps-{{ checksum "pyproject.toml" }}-{{ checksum "uv.lock" }}
      - uv-deps-

- save_cache:
    key: uv-deps-{{ checksum "pyproject.toml" }}-{{ checksum "uv.lock" }}
    paths:
      - ~/.cache/uv
```

**2. Parallel Builds**
```yaml
- run:
    name: Build Cython with parallel jobs
    command: |
      python build.py build_ext --inplace --parallel 4
```

## Customization

### Adding New Test Steps
```yaml
- run:
    name: Custom test step
    command: |
      # Your custom test commands here
      python -m pytest custom_tests/
```

### Adding New Platforms
```yaml
test_macos:
  macos:
    xcode: "15.0"
  steps:
    # Same steps as Linux but on macOS
```

### Modifying Python Versions
```yaml
# Add to comprehensive_test workflow
test_python_312:
  docker:
    - image: cimg/python:3.12
  # ... rest of job definition
```

## Monitoring

### Build Status Badge
Add to your README.md:
```markdown
[![CircleCI](https://circleci.com/gh/yourusername/virtmanager-win.svg?style=svg)](https://circleci.com/gh/yourusername/virtmanager-win)
```

### Notifications
Configure in CircleCI project settings:
- Email notifications for failed builds
- Slack integration for team notifications
- GitHub status checks

## Security Considerations

- No secrets are hardcoded in configuration files
- Dependencies are installed from trusted sources
- Build artifacts are stored securely
- Limited permissions for CI operations

## Support

For issues with:
- **CircleCI setup**: Check [CircleCI documentation](https://circleci.com/docs/)
- **uv package manager**: Check [uv documentation](https://docs.astral.sh/uv/)
- **Cython builds**: Check project's `build.py` and documentation
- **This configuration**: Open an issue in the project repository