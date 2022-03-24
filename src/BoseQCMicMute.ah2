;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; BoseQCMicMute v1.1.0
;;
;; Control microphone mute on Bose QC35 and QC45 headphones by pressing the
;; "action" button located between the volume buttons on the right earcup.
;;
;; single press == Media_Play_Pause == Toggle mute state
;; double press == Media_Next       == Mute all microphone devices
;; triple press == Media_Prev       == Unmute all microphone devices
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Copyright (c) 2022 Allen Derusha allen@derusha.org
;;
;; Licensed under MIT License
;;
;; Permission is hereby granted, free of charge, to any person obtaining a copy
;; of this software and associated documentation files (the "Software"), to deal
;; in the Software without restriction, including without limitation the rights
;; to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
;; copies of the Software, and to permit persons to whom the Software is
;; furnished to do so, subject to the following conditions:
;;
;; The above copyright notice and this permission notice shall be included in all
;; copies or substantial portions of the Software.
;;
;; THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
;; IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
;; FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
;; AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
;; LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
;; OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
;; SOFTWARE.
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Global variables
softwareVersion := "1.1.0"	; Current release version
beepMuteFreq := 350	; Frequency in Hertz of tone played when muting
beepMuteDuration := 500	; Duration in msec of tone played when muting
beepUnmuteFreq := 700	; Frequency in Hertz of tone played when unmuting
beepUnmuteDuration := 500	; Duration in msec of tone played when unmuting
beepEnabled := 1
toastEnabled := 1

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Compiler directives
#NoTrayIcon	; Hide our tray icon until we determine current mute state
;@Ahk2Exe-AddResource MicUnmuted.ico, 1
;@Ahk2Exe-AddResource MicMuted.ico, 2
;@Ahk2Exe-SetMainIcon MicUnmuted.ico
;@Ahk2Exe-SetCompanyName allen@derusha.org
;@Ahk2Exe-SetCopyright Copyright (c) 2022 Allen Derusha allen@derusha.org
;@Ahk2Exe-SetVersion 1.1.0
;@Ahk2Exe-SetName Bose QC Mic Mute
;@Ahk2Exe-SetDescription Control microphone mute on Bose QC35 and QC45 headphones

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load icon resources from ourself
MICUNMUTED := LoadPicture(A_ScriptName, "Icon1", &IconType)
MICMUTED := LoadPicture(A_ScriptName, "Icon2", &IconType)

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Load saved settings from the registry
ReadSavedSettings()

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Create taskbar menu
A_TrayMenu.Delete()	; Remove the standard menu items
A_TrayMenu.Add("&About BoseQCMicMute", MenuHandlerAbout)
A_TrayMenu.Add()
A_TrayMenu.Add("Microphones are:", MenuHandlerMuteToggle)
A_TrayMenu.Add()
A_TrayMenu.Add("Enable toast notification", MenuHandlerEnableToast)
A_TrayMenu.Add("Disable toast notification", MenuHandlerDisableToast)
A_TrayMenu.Add()
A_TrayMenu.Add("Enable audio notification", MenuHandlerEnableBeep)
A_TrayMenu.Add("Disable audio notification", MenuHandlerDisableBeep)
A_TrayMenu.Add()
A_TrayMenu.Add("&Mute all microphones", MenuHandlerMuteAll)
A_TrayMenu.Add("&Unmute all microphones", MenuHandlerUnMuteAll)
A_TrayMenu.Add("&Toggle mute status", MenuHandlerMuteToggle)
A_TrayMenu.Add()
A_TrayMenu.Add("E&xit BoseQCMicMute", MenuHandlerExit)
A_TrayMenu.Default := "&Toggle mute status"	; Set default action to toggle mute
A_TrayMenu.ClickCount := 1	; Single-click icon to trigger default action
if (beepEnabled = 1) {	; Place checkmark for beepEnabled
  A_TrayMenu.Check("Enable audio notification")
} else {
  A_TrayMenu.Check("Disable audio notification")
}
if (toastEnabled = 1) {	; Place checkmark for toastEnabled
  A_TrayMenu.Check("Enable toast notification")
} else {
  A_TrayMenu.Check("Disable toast notification")
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Collect the mute status of the first audio capture device found, declare that
;; our "Global" state, and set everything else to match
micMute := GetMicMute()
if (micMute = 0) {	; the first device we found was unmuted, so set all other devices unmuted
  TraySetIcon "HICON:" MICUNMUTED
  SetGlobalMicMute(0)
} else {
  TraySetIcon "HICON:" MICMUTED
  SetGlobalMicMute(1)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Show tray icon now that everything is sorted out
A_IconHidden := 0

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Setup keyboard hook and a timer to re-hook our hotkeys every 15 seconds
#UseHook true
InstallKeybdHook(true, true)
SetTimer ReHookHotkeys, 15000

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Hotkeys
Media_Play_Pause:: {	; Single press of action button: Toggle mute state
  ToggleGlobalMicMute
}

Media_Next:: {	; Double press of action button: Mute all mics
  SetGlobalMicMute(1)
  NotifyMuted()
}

Media_Prev:: {	; Triple press of action button: Unmute all mics
  NotifyUnmuted()
  SetGlobalMicMute(0)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
SetGlobalMicMute(muteState) {	; Loop through all our audio capture devices and set mute state
  loop {	; Loop through every sound device looking for a capture component
    try	; Collect the device name
      deviceName := SoundGetName(, deviceIndex := A_Index)
    catch	; No more devices left
      break
    loop {	; Loop through every component on this device
      try
        componentName := SoundGetName(componentIndex := A_Index, deviceIndex)
      catch	; No more components
        break
      if (componentName = "Capture") {	; We found a capture device, try and mute it
        try SoundSetMute(muteState, componentIndex, deviceIndex)
      }
    }
  }
}

GetMicMute()
{	; Loop through all our audio capture devices and return the mute
  ; status of the first device to respond to our querey.  Return 0
  ; if no devices could be queried.
  muteState := ""
  loop {	; Loop through every sound device
    try	; Collect the device name
      deviceName := SoundGetName(, deviceIndex := A_Index)
    catch	; No more devices
      return 0
    loop {	; Loop through every component on this device
      try
        componentName := SoundGetName(componentIndex := A_Index, deviceIndex)
      catch	; No more components for this device
        break
      if (componentName = "Capture") {
        try muteState := SoundGetMute(componentIndex, deviceIndex)
        if (muteState != "")
        {
          return muteState
        }
      }
    }
  }
  return 0
}

ToggleGlobalMicMute()
{	; Toggle mute state on all devices
  micMute := GetMicMute()
  if (micMute = 0) {
    SetGlobalMicMute(1)
    NotifyMuted()
  } else {
    NotifyUnmuted()
    SetGlobalMicMute(0)
  }
}

NotifyMuted()
{	; Update UI and notify user that we are muting mics
  global beepEnabled
  global toastEnabled
  MICMUTED := LoadPicture(A_ScriptName, "Icon2", &IconType)
  TraySetIcon "HICON:" MICMUTED
  A_TrayMenu.Rename("3&", "Microphones are: Muted")
  A_TrayMenu.Check("&Mute all microphones")
  A_TrayMenu.Uncheck("&Unmute all microphones")
  A_IconTip := "Microphones muted"
  if (toastEnabled = 1) {
    TrayTip "Microphones muted", "Bose QC Mic Mute", 20
  }
  if (beepEnabled = 1) {
    SoundBeep beepMuteFreq, beepMuteDuration
  }
}

NotifyUnmuted() {	; Update UI and notify user that we are unmuting mics
  global beepEnabled
  global toastEnabled
  global MICUNMUTED
  MICUNMUTED := LoadPicture(A_ScriptName, "Icon1", &IconType)
  TraySetIcon "HICON:" MICUNMUTED
  A_TrayMenu.Rename("3&", "Microphones are: Active")
  A_TrayMenu.Check("&Unmute all microphones")
  A_TrayMenu.Uncheck("&Mute all microphones")
  A_IconTip := "Microphones active"
  if (toastEnabled = 1) {
    TrayTip "Microphones active", "Bose QC Mic Mute", 20
  }
  if (beepEnabled = 1) {
    SoundBeep beepUnmuteFreq, beepUnmuteDuration
  }
}

ReadSavedSettings() {	; Read any saved settings from the registry and assign a default if nothing found
  global beepEnabled := RegRead("HKEY_CURRENT_USER\Software\BoseQCMicMute", "beepEnabled", 1)
  global toastEnabled := RegRead("HKEY_CURRENT_USER\Software\BoseQCMicMute", "toastEnabled", 1)
}

WriteSavedSettings() {	; Write settings to the registry
  global beepEnabled
  global toastEnabled
  RegWrite beepEnabled, "REG_DWORD", "HKEY_CURRENT_USER\Software\BoseQCMicMute", "beepEnabled"
  RegWrite toastEnabled, "REG_DWORD", "HKEY_CURRENT_USER\Software\BoseQCMicMute", "toastEnabled"
  InstallKeybdHook(true, true)
}

ReHookHotkeys() {	; Re-register keyboard hook
  InstallKeybdHook(true, true)
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Menu handlers
MenuHandlerAbout(ItemName, ItemPos, MyMenu) {
  MsgBox "BoseQCMicMute v" . softwareVersion . "Control global microphone muting with the 'action'`nbutton on Bose QuietComfort headphones.`n`nhttps://github.com/aderusha/BoseQCMicMute", "About BoseQCMicMute v" softwareVersion, "iconi"
}

MenuHandlerExit(ItemName, ItemPos, MyMenu) {
  ExitApp 0
}

MenuHandlerMuteAll(ItemName, ItemPos, MyMenu) {
  SetGlobalMicMute(1)
  NotifyMuted()
  InstallKeybdHook(true, true)
}

MenuHandlerUnMuteAll(ItemName, ItemPos, MyMenu) {
  NotifyUnmuted()
  SetGlobalMicMute(0)
  InstallKeybdHook(true, true)
}

MenuHandlerMuteToggle(ItemName, ItemPos, MyMenu) {
  ToggleGlobalMicMute()
  InstallKeybdHook(true, true)
}

MenuHandlerEnableToast(ItemName, ItemPos, MyMenu) {
  A_TrayMenu.Check("Enable toast notification")
  A_TrayMenu.Uncheck("Disable toast notification")
  global toastEnabled := 1
  WriteSavedSettings()
}

MenuHandlerDisableToast(ItemName, ItemPos, MyMenu) {
  A_TrayMenu.Check("Disable toast notification")
  A_TrayMenu.Uncheck("Enable toast notification")
  global toastEnabled := 0
  WriteSavedSettings()
}

MenuHandlerEnableBeep(ItemName, ItemPos, MyMenu) {
  A_TrayMenu.Check("Disable audio notification")
  A_TrayMenu.Uncheck("Enable audio notification")
  global beepEnabled := 1
  WriteSavedSettings()
}

MenuHandlerDisableBeep(ItemName, ItemPos, MyMenu) {
  A_TrayMenu.Check("Disable audio notification")
  A_TrayMenu.Uncheck("Enable audio notification")
  global beepEnabled := 0
  WriteSavedSettings()
}