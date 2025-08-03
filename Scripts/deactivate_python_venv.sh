#!/bin/bash

# Check if we are inside a virtual environment and deactivate the venv if we are.
if [[ -n "$VIRTUAL_ENV" ]]; then
  echo "You are currently in a virtual environment:"
  echo "    $VIRTUAL_ENV"

  echo "Deactivating..."
  deactivate
  echo "Virtual environment deactivated."

else
  echo "You are NOT in a virtual environment."
fi
