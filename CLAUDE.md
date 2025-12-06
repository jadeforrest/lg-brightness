# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

This is a macOS utility that automatically fixes an LG UltraFine 5K monitor brightness bug where the display doesn't restore to full brightness after waking from sleep. The solution uses `sleepwatcher` to detect wake events and `ddcctl` (or `m1ddc`) to send DDC/CI commands to the monitor.

## Core Architecture

The system consists of three main components:

1. **fix-lg-brightness.sh** - The core brightness fix script that toggles brightness 99% → 100% to force DDC/CI command transmission
2. **install.sh** - Sets up the LaunchAgent and installs dependencies via Homebrew
3. **uninstall.sh** - Removes the LaunchAgent configuration

### How It Works

- `sleepwatcher` monitors system sleep/wake events via a LaunchAgent
- On wake, it executes `fix-lg-brightness.sh`
- The script waits 2 seconds for system stabilization, then uses DDC/CI tools to toggle brightness
- Supports both `ddcctl` (primary) and `m1ddc` (fallback) for DDC/CI communication
- All activity is logged to `~/Library/Logs/lg-brightness-fix.log`

### LaunchAgent Configuration

The installer creates `~/Library/LaunchAgents/de.bernhard-baehr.sleepwatcher.plist` which:
- Runs sleepwatcher with verbose mode (`-V`)
- Watches for wake events (`-w`) and executes the fix script
- Keeps the daemon alive continuously
- Handles both Apple Silicon (`/opt/homebrew/bin`) and Intel (`/usr/local/bin`) Homebrew paths

## Testing

Test the brightness fix manually:
```bash
./fix-lg-brightness.sh
```

Test the complete wake behavior:
```bash
# Put Mac to sleep, wake it, then check logs
tail -f ~/Library/Logs/lg-brightness-fix.log
```

Check if sleepwatcher is running:
```bash
launchctl list | grep sleepwatcher
```

Find the correct display ID if not display 1:
```bash
ddcctl -l
```

## Installation/Uninstallation

Install:
```bash
./install.sh
```

Uninstall:
```bash
./uninstall.sh
# Optionally remove Homebrew packages:
brew uninstall sleepwatcher ddcctl
```

## Key Implementation Details

- **Display ID**: Hardcoded to `1` in fix-lg-brightness.sh (line 19). Edit if LG monitor uses different ID.
- **Wake delay**: 2-second sleep after wake (line 15) allows system to stabilize before sending DDC/CI commands.
- **Brightness toggle timing**: 0.2-second delay between 99% and 100% commands (lines 26, 32) ensures commands are distinct.
- **Logging**: All script activity appends to `~/Library/Logs/lg-brightness-fix.log` with timestamps.
- **Tool fallback**: Checks for `ddcctl` first, falls back to `m1ddc` if not found.

## Dependencies

- macOS (Apple Silicon or Intel)
- Homebrew
- sleepwatcher (via Homebrew)
- ddcctl or m1ddc (via Homebrew)

## Common Issues

If the brightness fix doesn't work:
1. Verify display ID with `ddcctl -l` and update DISPLAY_ID in fix-lg-brightness.sh
2. Check Terminal has Accessibility permissions (System Settings → Privacy & Security → Accessibility)
3. Review error logs at `~/Library/Logs/sleepwatcher.error.log`
