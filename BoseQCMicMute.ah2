;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;;
;; BoseQCMicMute v1.0.0
;;
;; Control microphone mute on Bose QC35 and QC45 headphones by pressing the
;; "action" button located between the volume buttons on the right earcup.
;;
;; single press == Media_Play_Pause == Toggle mute state
;; double press == Media_Next       == Mute all microphone devices
;; triple press == Media_Prev       == Unmute all microphone devices
;;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Copyright (c) 2021 Allen Derusha allen@derusha.org
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
softwareVersion := "1.0.0"	; Current release version
beepMuteFreq := 350	; Frequency in Hertz of tone played when muting
beepMuteDuration := 500	; Duration in msec of tone played when muting
beepUnmuteFreq := 700	; Frequency in Hertz of tone played when unmuting
beepUnmuteDuration := 500	; Duration in msec of tone played when unmuting
iconMutedFilename := A_ScriptDir . "\MicMuted.ico"	; Filename for icon shown while muted
iconMutedResource := 1	; Resource ID for icon shown while muted
iconUnmutedFilename := A_ScriptDir . "\MicUnmuted.ico"	; Filename for icon shown while unmuted
iconUnmutedResource := 1	; Resource ID for icon shown while munuted
#NoTrayIcon	; Hide our tray icon until we determine current mute state

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Compiler directives
;@Ahk2Exe-AddResource MicUnmuted.ico, MICUNMUTED
;@Ahk2Exe-AddResource MicMuted.ico, MICMUTED
;@Ahk2Exe-SetMainIcon MicUnmuted.ico
;@Ahk2Exe-SetCompanyName allen@derusha.org
;@Ahk2Exe-SetCopyright Copyright (c) 2021 Allen Derusha allen@derusha.org
;@Ahk2Exe-SetVersion 1.0.0
;@Ahk2Exe-SetName Bose QC Mic Mute
;@Ahk2Exe-SetDescription Control microphone mute on Bose QC35 and QC45 headphones

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Create taskbar menu
A_TrayMenu.Delete()	; Remove the standard menu items
A_TrayMenu.Add("&About BoseQCMicMute", MenuHandlerAbout)
A_TrayMenu.Add()
A_TrayMenu.Add("Microphones are:", MenuHandlerMuteToggle)
A_TrayMenu.Add()
A_TrayMenu.Add("&Mute all microphones", MenuHandlerMuteAll)
A_TrayMenu.Add("&Unmute all microphones", MenuHandlerUnMuteAll)
A_TrayMenu.Add("&Toggle mute status", MenuHandlerMuteToggle)
A_TrayMenu.Add()
A_TrayMenu.Add("E&xit BoseQCMicMute", MenuHandlerExit)
A_TrayMenu.Default := "&Toggle mute status"	; Set default action to toggle mute
A_TrayMenu.ClickCount := 1	; Single-click icon to trigger default action

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Collect the mute status of the first audio capture device found, declare that
;; our "Global" state, and set everything else to match
micMute := GetMicMute()
if (micMute = 0)
{	; the first device we found was unmuted, so set all other devices unmuted
  SetGlobalMicMute(0)
} else
{	; the first device we found was muted, so set all other devices muted
  SetGlobalMicMute(1)
}
A_IconHidden := false	; Show our tray icon now that our mute state is sorted

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Hotkeys
Media_Play_Pause::
{	; Single press of action button
  ToggleGlobalMicMute
}

Media_Next::
{	; Double press of action button
  SetGlobalMicMute(1)
  SoundBeep beepMuteFreq, beepMuteDuration
}

Media_Prev::
{	; Triple press of action button
  SetGlobalMicMute(0)
  SoundBeep beepUnmuteFreq, beepUnmuteDuration
}

;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; Functions
SetGlobalMicMute(muteState)
{	; Loop through all our audio capture devices and set mute state
  if (muteState = 0)
  {	; We're trying to unmute so update status indicators
    A_TrayMenu.Rename("3&", "Microphones are: Active")
    A_TrayMenu.Check("&Unmute all microphones")
    A_TrayMenu.Uncheck("&Mute all microphones")
    A_IconTip := "Microphones active"
    TraySetIcon(iconUnmutedFilename, iconUnmutedResource)
    TrayTip "Microphones active", "Bose QC Mic Mute", 20
  } else {	; We're trying to do something that's not unmute
    muteState := 1
    A_TrayMenu.Rename("3&", "Microphones are: Muted")
    A_TrayMenu.Check("&Mute all microphones")
    A_TrayMenu.Uncheck("&Unmute all microphones")
    A_IconTip := "Microphones muted"
    TraySetIcon(iconMutedFilename, iconMutedResource)
    TrayTip "Microphones muted", "Bose QC Mic Mute", 20
  }
  loop
  {	; Loop through every sound device looking for a capture component
    try	; Collect the device name
      deviceName := SoundGetName(, deviceIndex := A_Index)
    catch	; No more devices left
      break
    loop
    {	; Loop through every component on this device
      try
        componentName := SoundGetName(componentIndex := A_Index, deviceIndex)
      catch	; No more components
        break
      if (componentName = "Capture")
      {	; We found a capture device, try and mute it
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
  loop
  {	; Loop through every sound device
    try	; Collect the device name
      deviceName := SoundGetName(, deviceIndex := A_Index)
    catch	; No more devices
      return 0
    loop
    {	; Loop through every component on this device
      try
        componentName := SoundGetName(componentIndex := A_Index, deviceIndex)
      catch	; No more components for this device
        break
      if (componentName = "Capture")
      {
        try muteState := SoundGetMute(componentIndex, deviceIndex)
        if (muteState != "")
        {
          return muteState
        }
      }
    }
  }
}

ToggleGlobalMicMute()
{	; Toggle mute state on all devices
  micMute := GetMicMute()
  if (micMute = 0)
  {
    SetGlobalMicMute(1)
    SoundBeep beepMuteFreq, beepMuteDuration
  } else
  {
    SetGlobalMicMute(0)
    SoundBeep beepUnmuteFreq, beepUnmuteDuration
  }
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
  SoundBeep beepMuteFreq, beepMuteDuration
}

MenuHandlerUnMuteAll(ItemName, ItemPos, MyMenu) {
  SetGlobalMicMute(0)
  SoundBeep beepUnmuteFreq, beepUnmuteDuration
}

MenuHandlerMuteToggle(ItemName, ItemPos, MyMenu) {
  ToggleGlobalMicMute
}