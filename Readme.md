# TM-OSC-HUD

## Overview

TM-OSC-HUD is a small macOS utility that shows an on-screen volume HUD compatible with RME TotalMix when the main volume changes.

It is useful when using external controllers like the RME ARC USB and TotalMix is running in the background, to get a visual on the current volume.

## Configuration

TM-OSC-HUD runs as a local OSC receiver.

**Default Port:** `9001`  
**Default Address:** `/1/mastervolumeVal`

## Installation

1. Download **TM-OSC-HUD-macOS.zip** from [here](https://nightly.link/modularev/tm-volume-hud/workflows/macos-build/main/TM-OSC-HUD-macOS.zip) or via GitHub [Actions](https://github.com/modularev/tm-volume-hud/actions) (from the Artifacts section)
1. Unzip and move `TM-OSC-HUD.app` to `/Applications/`
2. Run this command in **Terminal**:

```bash
xattr -cr /Applications/TM-OSC-HUD.app
```

4. Open the app from your Applications folder.

**Security note**: As TM-OSC-HUD is currently unsigned, the command above removes the macOS quarantine flag.

## Setup

1. Open TotalMix.
2. Go to **Options > Mixer Settings...**
3. Open the **OSC** tab.
4. Set the Host **Remote Controller Address** to `127.0.0.1`
5. Set the **Port (outgoing)** to `9001` (or your custom port)
6. Go to **Options** and **Enable OSC Control**.
7. Launch **TM-OSC-HUD**

The HUD will appear automatically when the main volume changes.


| Styles                |                             |
| --------------------- | --------------------------- |
| ![pro](img/pro.png)   | ![classic](img/classic.png) |
| ![dark](img/dark.png) | ![light](img/light.png)     |
