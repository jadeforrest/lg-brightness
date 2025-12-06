#!/bin/bash
# Installation script for LG 5K brightness fix on wake

set -e

SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
WAKEUP_SCRIPT="$SCRIPT_DIR/fix-lg-brightness.sh"

echo "=== LG 5K Brightness Fix Installer ==="
echo ""

# Check if Homebrew is installed
if ! command -v brew &> /dev/null; then
    echo "ERROR: Homebrew is not installed. Please install it first."
    exit 1
fi

# Install sleepwatcher
echo "Installing sleepwatcher..."
if ! brew list sleepwatcher &> /dev/null; then
    brew install sleepwatcher
else
    echo "sleepwatcher already installed"
fi

# Install ddcctl
echo "Installing ddcctl..."
if ! brew list ddcctl &> /dev/null; then
    brew install ddcctl
else
    echo "ddcctl already installed"
fi

# Create LaunchAgent plist for sleepwatcher
PLIST_FILE="$HOME/Library/LaunchAgents/de.bernhard-baehr.sleepwatcher.plist"
echo ""
echo "Creating sleepwatcher LaunchAgent..."

cat > "$PLIST_FILE" << EOF
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>de.bernhard-baehr.sleepwatcher</string>
    <key>ProgramArguments</key>
    <array>
        <string>/opt/homebrew/bin/sleepwatcher</string>
        <string>-V</string>
        <string>-w</string>
        <string>$WAKEUP_SCRIPT</string>
    </array>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
    <key>StandardOutPath</key>
    <string>$HOME/Library/Logs/sleepwatcher.log</string>
    <key>StandardErrorPath</key>
    <string>$HOME/Library/Logs/sleepwatcher.error.log</string>
</dict>
</plist>
EOF

# Check if using Intel or Apple Silicon for correct brew path
if [ -d "/opt/homebrew/bin" ]; then
    BREW_BIN="/opt/homebrew/bin/sleepwatcher"
elif [ -d "/usr/local/bin" ]; then
    BREW_BIN="/usr/local/bin/sleepwatcher"
    # Update plist with Intel path
    sed -i '' 's|/opt/homebrew/bin/sleepwatcher|/usr/local/bin/sleepwatcher|g' "$PLIST_FILE"
else
    echo "ERROR: Cannot find Homebrew bin directory"
    exit 1
fi

echo "Created $PLIST_FILE"

# Unload existing agent if running
echo ""
echo "Loading sleepwatcher LaunchAgent..."
launchctl unload "$PLIST_FILE" 2>/dev/null || true
launchctl load "$PLIST_FILE"

echo ""
echo "=== Installation Complete ==="
echo ""
echo "The brightness fix will now run automatically when your Mac wakes from sleep."
echo "Logs will be written to:"
echo "  - $HOME/Library/Logs/lg-brightness-fix.log"
echo "  - $HOME/Library/Logs/sleepwatcher.log"
echo ""
echo "To test manually, run: $WAKEUP_SCRIPT"
echo "To uninstall, run: ./uninstall.sh"
