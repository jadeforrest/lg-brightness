#!/bin/bash
# Fix LG 5K monitor brightness after wake from sleep
# This works around a macOS bug where the system thinks brightness is at 100%
# but the monitor doesn't receive the DDC/CI command

LOG_FILE="$HOME/Library/Logs/lg-brightness-fix.log"

log_message() {
    echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
}

log_message "Wake detected, fixing LG 5K brightness..."

# Wait a moment for the system to fully wake
sleep 2

# Try to find the LG display ID
# LG UltraFine 5K typically shows as display 1
DISPLAY_ID=1

# Use m1ddc to toggle brightness: set to 99%, then back to 100%
# This forces the DDC/CI command to be sent to the monitor
if command -v m1ddc &> /dev/null; then
    log_message "Using m1ddc to toggle brightness"
    m1ddc set luminance 99 "$DISPLAY_ID" >> "$LOG_FILE" 2>&1
    sleep 0.2
    m1ddc set luminance 100 "$DISPLAY_ID" >> "$LOG_FILE" 2>&1
    log_message "Brightness fix complete"
else
    log_message "ERROR: m1ddc not found. Please install it with: brew install m1ddc"
    exit 1
fi
