#!/bin/bash

echo "Starting Firebase data seeding using REST API..."
echo

# Navigate to scripts directory
cd "$(dirname "$0")"

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "ERROR: Python 3 is not installed"
    echo "Please install Python 3.7 or higher"
    exit 1
fi

echo "Python version:"
python3 --version
echo

echo "Installing required packages..."
pip3 install -r requirements.txt

echo
echo "Running REST API data seeding script..."
python3 add_data_rest.py

echo
echo "Seeding completed!"
