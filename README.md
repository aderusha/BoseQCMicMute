# Bose QC Mic Mute

## Control Windows microphone mute with the multi-function button on Bose QuietComfort headphones

Bose QuietComfort models 35, 35ii, and 45 each have three buttons on the bottom of the right ear cup.  The top and bottom buttons control volume up and down in all modes.  The function of the middle "multi-function" button depends on the active bluetooth profile.

![Bose QC buttons](https://github.com/aderusha/BoseQCMicMute/blob/main/images/qcbuttons.png?raw=true)

When attached to a Windows desktop via bluetooth, this button will typically issue track control commands as shown below:

| Button press           | Action         |
|------------------------|----------------|
| Single press MFB       | Play/pause     |
| Double press MFB       | Next track     |
| Triple press MFB       | Previous track |

---

This program will catch presses of the Multi-function button and control the mute status on **all attached recording devices**.

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

Developed with [AutoHotkey v2](https://www.autohotkey.com/v2/)