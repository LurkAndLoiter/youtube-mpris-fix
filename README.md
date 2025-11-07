# YouTube MPRIS Fix

A browser/host fix addressing MPRIS metadata bugs on YouTube and YouTube Music

Tested on:

- Google Chrome
- Chromium
- Brave
- Vivaldi
- Microsoft Edge
- Opera
- Firefox
- Librewolf
- Zen

*This should be compatible with any Chromium or Firefox browser. If your browser is not listed, see Manual install; otherwise, install.sh should work*

*If you'd like a browser supported that is not currently please open an issue about it.*

---

## The Problem

YouTube is a Single-Page Application (SPA) that loads new videos dynamically without a full page refresh. Because of this, MPRIS often does not detect video changes and metadata updates.

## The Solution

*Seeking updates MPRIS.*

Create a native messaging host call that creates a socket listener for the browser's MPRIS player status and call a host machine MPRIS seek 1- on status Playing.

> [!NOTE]
> Ideally, we would set position to the current position. Unfortunately, position is an element that is unreliable due to SPA; thus, the least invasive fix is to always seek back 0 seconds (Youtube does not support a seconds argument and thus will default to 5 seconds)
> If it's the beginning of a video, this seeks to 0 else, it'll resume play 5s back from the current real player position.

---

## Installation:

### Chromium

1. Clone or download this repository.

2. Navigate to the repositories directory and run the install.sh(see Manual install if you don't trust this.).

3. Open browser and go to `chrome://extensions` (or `yourbrowser://extensions`).

4. Toggle "Developer mode" on.

5. Click "Load unpacked".

6. Select the extension directory (the folder that contains `manifest.json`).

7. The extension should appear in the extensions list; reload the extension if you make alterations.

### Firefox

1. Clone or download this repository.

2. Navigate to the repositories directory and run the install.sh(see Manual install if you prefer not to run this.).

> **TEMPORARY INSTALL**
> 
> 3. In Firefox, navigate to`about:debugging`
> 4. Click on `This Firefox` on the left
> 5. Click the `Load Temporary Add-on...` button
> 6. Select the `mpris_youtube_fix.xpi` inside the `youtube-mpris-fix` directory
> 7. The extension will be active until you close Firefox or disable the extension.

> **PERMANENT INSTALL**
> 
> 3. In Firefox, navigate to `about:addons`
> 4. Click the settings cog wheel `Tools for all add-ons` in the top right.
> 5. Click "Install Add-on From File"
> 6. Select the `mpris_youtube_fix.xpi`
> 7. Click `add` on the pop-up *see note for permissions overview*
> 8. The extension will be active until you remove or disable it.
 
> [!NOTE]
> #### Permissions pop-up
> - **Exchange messages with programs other than $browser**
>   - This is regarding using a host script.
>   - See mpris_helper.json and mpris_helper.sh
> - **Access browser tabs**
>   - Tracks tabs for url *youtube.com/*
>   - See background.js

## Manual install (for users who prefer not to run install.sh)

You must install two files to the native mesaging host directory for your browser:
- Chromium-based: `$HOME/.config/YOURCHROMIUMBROWSER/NativeMessagingHosts/`
- Firefox-based: `$HOME/.YOURFIREFOXBROWSER/native-messaging-hosts/`

Edit the following files before installing:
- mpris_helper.json
  - alteration: Change `"path": "blank"` to be `"path": "/root/fullfromroottoscript/pathof/mpris_helper.sh"`
- mpris_helper.sh
  - alteration: Change `browser=blank` to `browser=BrowserplayerctlNAME`
  - for the playerctl name exclude any `.instance12345` just use `brave`, `chromium`, etc
  - **DO NOT** quote the BrowserplayerctlName do not use `browser="chromium"` or `browser='chromium'` just write `browser=chromium`

 ---

## FAQ

### What is in mpris_youtube_fix.xpi?
- Firefox compliant manifest.json
  - service_worker → scripts
  - add browser specific section to declare app id.
- Firefox compliant background.json
  - chrome.* → browser.*
- MIT License copy

### How does it work?

- install.sh see manual install; this is roughly what the script attempts to accomplish
- background.js monitors tabs for `youtube.com` if one exists, it sends a start message to our native host. When all Youtube tabs are closed or when the browser is suspended, it will send a stop message to our native host.
- mpris_helper (native host) receives message start and stop.
  - The start will begin to follow the browser's MPRIS bus for status updates (playing, paused, stopped). Anytime the status becomes "Playing" it'll trigger a MPRIS negative seek, which will either move playback to 0 or move playback -5 seconds from the current real position. This seek forces the SPA to update MPRIS.
  - The stop will stop the native host.
