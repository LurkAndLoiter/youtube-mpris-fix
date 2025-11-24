# YouTube MPRIS Fix

A browser fix addressing MPRIS metadata bugs on YouTube and YouTube Music

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

---

## The Problem

YouTube is a Single-Page Application (SPA) that loads new videos dynamically without a full page refresh. Because of this, MPRIS often does not detect video changes and metadata updates. This also fixes firefox based browser position incrementing when paused.

## Our Solution's Approach

*Seeking updates MPRIS.*

On first frame loaded or PlaybackState 'play' we forcibly seek to the current position.

---

## Installation:

### Firefox

Firefox Add-Ons: [YouTube MPRIS](https://addons.mozilla.org/en-US/firefox/addon/youtube-mpris)

### Chromium

1. Clone or download this repository.

3. Open browser and go to `chrome://extensions` (or `yourbrowser://extensions`).

4. Toggle "Developer mode" on.

5. Click "Load unpacked".

6. Select the extension directory (the folder that contains `manifest.json`).

7. The extension should appear in the extensions list; reload the extension if you make alterations.

 ---
