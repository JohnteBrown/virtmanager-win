```bash
#!/bin/bash

echo "Starting Virtmanager-Win..."
echo

# Change to the script directory
cd "$(dirname "$0")" || exit 1

# Check if uv is available
if ! command -v uv >/dev/null 2>&1; then
    echo "Error: uv not found. Please install uv first."
    echo "Visit: https://docs.astral.sh/uv/getting-started/installation/"
    exit 1
fi

# If a virtual environment already exists, use it directly.
if [ -x ".venv/bin/python" ]; then
    echo "Virtual environment found. Using .venv/bin/python..."
else
    # Otherwise, create the environment and install dependencies via uv.
    echo "Virtual environment not found. Installing dependencies with uv..."

    if ! uv sync --no-install-project; then
        echo "Error: Failed to install dependencies."
        exit 1
    fi
fi

# Run the application
echo "Running application..."

if [ -x ".venv/bin/python" ]; then
    .venv/bin/python main.py
else
    uv run --no-sync python main.py
fi

# Check exit code
exit_code=$?

if [ "$exit_code" -ne 0 ]; then
    echo
    echo "Application exited with error code $exit_code"
fi

exit "$exit_code"
```