#!/bin/bash
# Complete Data Population Script
# This script fetches all Quran data for Play Store publishing

echo "=========================================="
echo "Quran App - Complete Data Population"
echo "=========================================="
echo ""

# Check if Python is installed
if ! command -v python3 &> /dev/null; then
    echo "Error: Python 3 is required but not installed."
    echo "Please install Python 3 and try again."
    exit 1
fi

# Check if requests library is installed
if ! python3 -c "import requests" 2>/dev/null; then
    echo "Installing required Python packages..."
    pip3 install requests
fi

# Run the data population script
echo "Starting data population..."
echo "This will fetch all 114 surahs with translations."
echo "This may take 30-60 minutes. Please be patient."
echo ""

python3 scripts/populate_all_data.py --output assets/data/

echo ""
echo "=========================================="
echo "Data population completed!"
echo "=========================================="
echo ""
echo "Next steps:"
echo "1. Verify the data files in assets/data/"
echo "2. Check for any missing translations"
echo "3. Test the app: flutter run"
echo "4. Build for release: flutter build appbundle --release"
