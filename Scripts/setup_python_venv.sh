#!/bin/bash

# Set variables
VENV_PATH="$HOME/GitHub/Main/Lenovo-T480/.venv"
REQ_FILE="$HOME/GitHub/Main/Lenovo-T480/requirements.txt"

# Check that requirements.txt exists
if [ ! -f "$REQ_FILE" ]; then
  echo "requirements.txt not found at $REQ_FILE"
  exit 1
fi

# Create the venv if it doesn't exist
if [ ! -d "$VENV_PATH" ]; then
  echo "Creating virtual environment at $VENV_PATH..."
  /opt/homebrew/bin/python3.12 -m venv "$VENV_PATH"
else
  echo "Virtual environment already exists at $VENV_PATH"
fi

# Activate the venv
echo "Activating virtual environment..."
source "$VENV_PATH/bin/activate"

# Upgrade pip and install requirements
echo "Installing Python packages from requirements.txt..."
pip install --upgrade pip
pip install -r "$REQ_FILE"

# Done
echo ""
echo "Virtual environment is ready."
echo "To activate it later, run:"
echo "source $VENV_PATH/bin/activate"

# Optional
echo ""
echo "Optional: Add this alias to your ~/.zshrc or ~/.bashrc:"
echo "alias ansible-win='source $VENV_PATH/bin/activate'"

# This is a fix for macOS concurrency/runtime warning that sometimes crashes or hangs processes.
# This disables the safety check causing the crash.
echo export OBJC_DISABLE_INITIALIZE_FORK_SAFETY=YES