# LG 5K Monitor Brightness Fix for macOS

Automatic fix for the macOS bug where LG 5K monitors don't restore to full brightness after waking from sleep.

## The Problem

macOS has a bug with LG UltraFine 5K monitors where:
- System thinks the brightness is at 100% after wake
- The monitor doesn't actually receive the DDC/CI brightness command
- Result: darker screen even though the slider shows 100%
- Manual workaround: adjust brightness slider to force a refresh

## The Solution

This tool automatically toggles the monitor brightness (99% → 100%) whenever your Mac wakes from sleep, forcing macOS to send the DDC/CI command to the monitor.

## Installation

1. Run the installation script:
```bash
./install.sh
```

This will:
- Install `sleepwatcher` (detects wake events)
- Install `ddcctl` (controls monitor via DDC/CI)
- Set up a LaunchAgent to run on wake
- Start the service immediately

## Testing

When connected to your LG 5K monitor, you can test manually:

```bash
./fix-lg-brightness.sh
```

Or test the wake behavior:
1. Put your Mac to sleep
2. Wake it up
3. Check the logs: `tail -f ~/Library/Logs/lg-brightness-fix.log`

## Logs

Monitor the behavior via these log files:
- `~/Library/Logs/lg-brightness-fix.log` - brightness fix activity
- `~/Library/Logs/sleepwatcher.log` - sleepwatcher output
- `~/Library/Logs/sleepwatcher.error.log` - sleepwatcher errors

## Uninstall

```bash
./uninstall.sh
```

To also remove the Homebrew packages:
```bash
brew uninstall sleepwatcher ddcctl
```

## Troubleshooting

### Display ID is wrong

If your LG monitor isn't display 1, find the correct ID:
```bash
ddcctl -l
```

Then edit `fix-lg-brightness.sh` and change `DISPLAY_ID=1` to the correct number.

### Nothing happens on wake

Check if sleepwatcher is running:
```bash
launchctl list | grep sleepwatcher
```

Check the logs for errors:
```bash
cat ~/Library/Logs/sleepwatcher.error.log
```

### Permission issues

ddcctl may need accessibility permissions. If it doesn't work:
1. Go to System Settings → Privacy & Security → Accessibility
2. Add Terminal or your terminal app if not already there

## How It Works

1. `sleepwatcher` monitors system sleep/wake events
2. On wake, it runs `fix-lg-brightness.sh`
3. The script uses `ddcctl` to send DDC/CI commands directly to the monitor
4. Toggling 99% → 100% forces the command to be sent even though macOS thinks it's already at 100%

## Requirements

- macOS (tested on Apple Silicon, should work on Intel)
- Homebrew
- LG UltraFine 5K monitor

## Credits

This workaround addresses a long-standing macOS bug with LG displays and DDC/CI communication.
