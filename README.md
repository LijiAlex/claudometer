# Claudometer

A tiny macOS menu bar app that shows your Claude usage limits at a glance —
the same session / weekly percentages as Claude Code's `/usage` panel.

![screenshot](docs/screenshot.png)

## Install

### Homebrew (recommended)
```bash
brew install LijiAlex/tap/claudometer
```
Then launch **Claudometer** from Spotlight.

### From source
```bash
git clone https://github.com/LijiAlex/claudometer.git
cd claudometer
make install
```
Requires macOS 13+ and Xcode Command Line Tools (`xcode-select --install`).

## First run
- Claudometer reads Claude Code's login token from your macOS Keychain.
  On first launch macOS asks permission for the `Claude Code-credentials`
  item — click **Always Allow**.
- You must have logged into Claude Code at least once (`claude`).

## Privacy
Your token never leaves your machine and is never written to disk.
The app makes exactly one network call: `GET https://api.anthropic.com/api/oauth/usage`,
the same endpoint Claude Code uses for `/usage`.

## What it shows
- **Menu bar:** current session usage %.
- **Popover:** session and weekly limits (all-models and per-model), each
  with a progress bar and reset time. Bars turn amber past 70% and red past 90%.

## License
MIT
