# Bose QC Mic Mute

## Control Windows microphone mute with the multi-function button on Bose QuietComfort headphones

Bose QuietComfort models 35, 35ii, and 45 each have three buttons on the bottom of the right ear cup.  The top and bottom buttons control volume up and down in all modes.  The function of the middle "multi-function button" (MFB) depends on the active bluetooth profile.

![Bose QC buttons](https://github.com/aderusha/BoseQCMicMute/blob/main/images/qcbuttons.png?raw=true)

When attached to a Windows desktop via bluetooth, this button will typically issue track control commands as shown below:

| Button press           | Action         |
|------------------------|----------------|
| Single press MFB       | Play/pause     |
| Double press MFB       | Next track     |
| Triple press MFB       | Previous track |

---

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

---

## Additional notes

* The headphones send media keys which are sometimes captured by media player software.  That behavior can prevent this tool from working.  [See this article](https://www.askvg.com/fix-media-keys-not-working-in-spotify-itunes-and-other-media-players/) for details on how you might deal with this.
* If you want to modify the source code, keep in mind that this is developed with [AutoHotkey v2](https://www.autohotkey.com/v2/).  The code will not work with v1 (which doesn't support modern sound interface access), so make sure you grab the right version