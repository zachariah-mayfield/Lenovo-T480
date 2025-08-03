#!/bin/bash

# Set path to your virtual environment
VENV_PATH="$HOME/GitHub/Main/Lenovo-T480/.venv"

# Check if the venv exists
if [ ! -d "$VENV_PATH" ]; then
  echo "Virtual environment not found at $VENV_PATH"
  echo "Did you forget to run the setup script?"
  exit 1
fi

# Activate the virtual environment
echo "Activating virtual environment at $VENV_PATH"
source "$VENV_PATH/bin/activate"

# Confirm activation
echo "Virtual environment activated. You are now in: $(which python)"

# Run the following to activate the Python Virtual Environment:
# source ~/GitHub/Main/Lenovo-T480/.venv/bin/activate

# -----------  Explanation - You can't just run ./activate_python_venv.sh - you have to copy and paste this code into the shell. --------------------
# source runs the script in the current shell so all environment changes persist.
# Running ./activate_python_venv.sh spawns a new shell process, which inherits your environment, but changes inside it don't affect your current shell.