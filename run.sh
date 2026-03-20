#!/bin/bash

echo "Starting Virtmanager-Win..."
echo

# Change to the script directory
cd "$(dirname "$0")"

# If a Poetry-created virtualenv already exists, use it directly.
if [ -x ".venv/bin/python" ]; then
    echo "Virtual environment found. Using .venv/bin/python..."
else
    # Otherwise, create/install dependencies via Poetry.
    if ! command -v poetry &> /dev/null; then
        echo "Error: Poetry not found. Please install Poetry first."
        exit 1
    fi

    echo "Virtual environment not found. Installing dependencies with Poetry..."
    POETRY_VIRTUALENVS_IN_PROJECT=true POETRY_NO_INTERACTION=1 poetry install --no-root
fi

# Run the application
echo "Running application..."
if [ -x ".venv/bin/python" ]; then
    .venv/bin/python main.py
else
    POETRY_VIRTUALENVS_IN_PROJECT=true POETRY_NO_INTERACTION=1 poetry run python main.py
fi

# Check exit code
exit_code=$?
if [ $exit_code -ne 0 ]; then
    echo
    echo "Application exited with error code $exit_code"
fi

exit $exit_code
