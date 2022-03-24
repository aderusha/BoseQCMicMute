# Bose QC Mic Mute

### Control Windows microphone mute with the multi-function button on Bose QuietComfort headphones

---

## How the Bose QuietComfort line handles media controls

Bose QuietComfort models 35, 35ii, and 45 each have three buttons on the bottom of the right ear cup.  The top and bottom buttons control volume up and down in all modes.  The function of the middle "multi-function button" (MFB) depends on the active bluetooth profile.

![Bose QC buttons](https://github.com/aderusha/BoseQCMicMute/blob/main/images/qcbuttons.png?raw=true)

When attached to a Windows desktop via bluetooth, this button will typically issue track control commands as shown below:

| Button press           | Action         |
|------------------------|----------------|
| Single press MFB       | Play/pause     |
| Double press MFB       | Next track     |
| Triple press MFB       | Previous track |

---

## How the Bose QC Mic Mute software works

This program will catch presses of the MFB and control the mute status on **all attached recording devices**.  This includes your webcam or any other audio recording devices, when triggered from the headset all currently-active audio recording devices will be muted and unmuted.

| Button press           | Action                 |
|------------------------|------------------------|
| Single press MFB       | Toggle global mic mute |
| Double press MFB       | Mute all microphones   |
| Triple press MFB       | Umute all microphones  |
| Single click tray icon | Toggle global mic mute |
| Right-click tray icon  | Control menu           |

Changes in mute status will alert the user in the following ways:

* Low tone is played through the headset on mic disable (muted)
* High tone is played through the headset on mic enable (unmuted)
* A Windows notification is briefly shown
* System tray icon and icon hover text (white icon = mic active, black icon = mic muted)

Audio and visual notifications can be enabled or disabled by right-clicking on the tray icon.

---

## How to install Bose QC Mic Mute

1. Download `BoseQCMicMute.exe` and run it.  That's it!

---

## Changelog

### v1.0.0
* Initial release

### v1.1.0 
* Single-file .exe, just download the file and run it wherever!
* Add options to enable or disable audio and visual alerts
* More aggressive hooking and re-hooking of media keys

---

## Additional notes

* **WINDOWS DEFENDER VIRUS DETECTED** - This is common for applications developed with AutoHotKey as it needs to monitor keyboard activity to catch the media keys being pressed.  That makes it look like a keylogger and may throw an error on download.  If you don't trust me, just [download the source](https://github.com/aderusha/BoseQCMicMute/source) and compile it with [AutoHotkey v2](https://www.autohotkey.com/v2/).
* The headphones send media keys which are sometimes captured by media player software.  That behavior can prevent this tool from working.  [See this article](https://www.askvg.com/fix-media-keys-not-working-in-spotify-itunes-and-other-media-players/) for details on how you might deal with this.  Version 1.1 includes several new features to address this issue.
* If you want to modify the source code, keep in mind that this is developed with [AutoHotkey v2](https://www.autohotkey.com/v2/).  The code will not work with v1 (which doesn't support modern sound interface access), so make sure you grab the right version.
* The AHK script attempts to load icon resources from itself, which will only work when running as the compiled .exe.  Running as an AHK2 script without compiling will not work.

---

## [Buy me a coffee](https://www.buymeacoffee.com/gW5rPpsKR)

[![Buy me a coffee](https://www.buymeacoffee.com/assets/img/custom_images/black_img.png)](https://www.buymeacoffee.com/gW5rPpsKR)

This project is powered by coffee.  [I might get a little weird about it at times](https://github.com/aderusha/RoastLearner), but it's not much of a stretch to suggest that coffee both powers and consumes a fair portion of my mental energy.  [Hook me up if you think this project is cool](https://www.buymeacoffee.com/gW5rPpsKR). Even a buck or three is appreciated - Thanks!