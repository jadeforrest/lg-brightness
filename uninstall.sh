#!/bin/bash
# Uninstall script for LG 5K brightness fix

set -e

PLIST_FILE="$HOME/Library/LaunchAgents/de.bernhard-baehr.sleepwatcher.plist"

echo "=== LG 5K Brightness Fix Uninstaller ==="
echo ""

# Unload and remove LaunchAgent
if [ -f "$PLIST_FILE" ]; then
    echo "Unloading sleepwatcher LaunchAgent..."
    launchctl unload "$PLIST_FILE" 2>/dev/null || true
    echo "Removing plist file..."
    rm "$PLIST_FILE"
    echo "LaunchAgent removed successfully"
else
    echo "LaunchAgent not found, nothing to uninstall"
fi

echo ""
echo "Uninstall complete. Note: sleepwatcher and ddcctl are still installed via Homebrew."
echo "To remove them completely, run:"
echo "  brew uninstall sleepwatcher ddcctl"
