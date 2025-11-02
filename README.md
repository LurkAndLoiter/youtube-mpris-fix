# Chromium YouTube MPRIS Patch

A Chromium Youtube patch addressing MPRIS metadata bugs on YouTube and YouTube Music

Tested on:

- Google Chrome
- Chromium
- Brave
- Vivaldi
- Microsoft Edge
- Opera

*This should be compatible with any chromium browser see Manual install if not listed else, install.sh works*

*If you'd like a chromium browser supported that is not currently please open an issue about it.*

There is a [firefox solution](https://github.com/d1BG/youtube-mpris-fix) by @D1BG.

## The Problem

YouTube is a Single-Page Application (SPA). It loads new videos dynamically without a full page refresh. This often means MPRIS fails to notice updates.

## The Solution

*Seeking updates MPRIS.*

create a native messaging host call that creates a socket listener for the browser's MPRIS player status and call a host machine MPRIS seek 1- on status Playing.

> [!NOTE]
> Ideally we would set position to the current position. Unfortunately position is an element that is unreliable due to SPA; thus the least invasive fix is to always seek back 0 seconds (youtube does not support a seconds argument and thus will default to 5 seconds)
> If it's the beginning of a video, this seeks to 0 else, it'll resume play 5s back from the current real player position.

## Installation:

1. Clone or download this repository.

2. navigate to the repositories directory and run the install.sh(see below section if you don't trust this.).

3. Open browser and go to `chrome://extensions` (or `yourbrowser://extensions`).

4. Toggle "Developer mode" on.

5. Click "Load unpacked".

6. Select the extension directory (the folder that contains `manifest.json`).

7. The extension should appear in the extensions list; reload the extension if you make alterations.

## Manual install because who would trust install.sh?

There are two files that need to be altered and moved into the browsers $HOME/.config/YOURCHROMIUMBROWSER/NativeMessagingHosts/ folder:

- mpris_helper.json
  - alteration: Change `"path": "blank"` to be `"path": "/root/fullfromroottoscript/pathof/mpris_helper.sh"`
- mpris_helper.sh
  - alteration: Change `browser=blank` to `browser=BrowserplayerctlNAME`
  - for the playerctl name exclude any `.instance12345` you just want `brave`, `chromium`, etc
  - **DO NOT** quote the BrowserplayerctlName do not use `browser="chromium"` or `browser='chromium'` just write `browser=chromium`

## How does it work?

- install.sh see manual install; this is roughly what the script attempts to accomplish
- background.js monitors tabs for `youtube.com` if one exists, it sends a start message to our native host. When all Youtube tabs are closed or when the browser is suspended, it will send a stop message to our native host.
- mpris_helper (native host) receives messages start and stops.
  - The start will begin to follow the browsers MPRIS bus for status updates (playing,paused,stopped). Anytime the status becomes "Playing" it'll trigger a MPRIS negative seek, which will either move playback to 0 or move playback -5 seconds from the current real position. This seek forces the SPA to update MPRIS.
  - The stop will stop the native host.
