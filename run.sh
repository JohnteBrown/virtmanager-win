#!/bin/bash

echo "Starting Virtmanager-Win..."
echo

# Change to the script directory
cd "$(dirname "$0")"

# Check if uv is available
if ! command -v uv &> /dev/null; then
    echo "Error: UV package manager not found. Please install UV first."
    echo "Visit: https://docs.astral.sh/uv/getting-started/installation/"
    exit 1
fi

# Check if virtual environment exists
if [ ! -d ".venv" ]; then
    echo "Virtual environment not found. Creating one..."
    uv sync
    if [ $? -ne 0 ]; then
        echo "Error: Failed to create virtual environment"
        exit 1
    fi
fi

# Run the application
echo "Running application..."
uv run python main.py

# Check exit code
exit_code=$?
if [ $exit_code -ne 0 ]; then
    echo
    echo "Application exited with error code $exit_code"
fi

exit $exit_code
