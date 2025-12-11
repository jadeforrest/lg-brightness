# LG 5K Monitor Brightness Fix for macOS

Automatic fix for the macOS bug where LG 5K monitors don't restore to full brightness after waking from sleep.

## Who Should Use This

This utility is for you if:
- You own an **LG UltraFine 5K monitor** (27MD5KL-B or 27MD5KA-B)
- You're running **macOS** (Apple Silicon or Intel)
- After waking your Mac from sleep, the **display remains dim** even though the brightness slider shows 100%
- You currently have to **manually adjust the brightness slider** after every wake to fix it

This is a known macOS bug with DDC/CI communication to LG displays. This tool automates the workaround.

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
- Install `m1ddc` (controls monitor via DDC/CI)
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
brew uninstall sleepwatcher m1ddc
```

## Troubleshooting

### Sleepwatcher not running

Check if sleepwatcher is running:
```bash
ps aux | grep sleepwatcher
launchctl list | grep sleepwatcher
```

If `LastExitStatus` is not 0, sleepwatcher failed to start. Check the error log:
```bash
cat ~/Library/Logs/sleepwatcher.error.log
```

### Display ID is wrong

If your LG monitor isn't display 1, find the correct ID:
```bash
m1ddc detect
```

Then edit `fix-lg-brightness.sh` and change `DISPLAY_ID=1` to the correct number.

### Permission issues

m1ddc may need accessibility permissions. If it doesn't work:
1. Go to System Settings → Privacy & Security → Accessibility
2. Add Terminal or your terminal app if not already there

## How It Works

1. `sleepwatcher` monitors system sleep/wake events via a LaunchAgent
2. On wake, it runs `fix-lg-brightness.sh` (after a 2-second delay for system stabilization)
3. The script uses `m1ddc` to send DDC/CI commands directly to the monitor
4. Toggling 99% → 100% forces the command to be sent even though macOS thinks it's already at 100%
5. All activity is logged to `~/Library/Logs/lg-brightness-fix.log`

## Requirements

- macOS (Apple Silicon or Intel)
- Homebrew
- LG UltraFine 5K monitor (27MD5KL-B or 27MD5KA-B)

## Technical Details

- Uses `m1ddc` for DDC/CI communication (works reliably on both Apple Silicon and Intel)
- Waits 2 seconds after wake for system stabilization before sending commands
- 0.2-second delay between brightness commands ensures they are distinct
- LaunchAgent keeps sleepwatcher running continuously

## Credits

This workaround addresses a long-standing macOS bug with LG displays and DDC/CI communication that has existed across multiple macOS versions.
