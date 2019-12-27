; AHK-Global-Gestures v1.05 - https://github.com/CheeseFrog/AHK-GlobalGestures

#NoEnv
#SingleInstance Force
#MaxHotkeysPerInterval 200
CoordMode, Mouse, Screen 
; SetDefaultMouseSpeed, 0
; SetMouseDelay, 1
noRclick:=0


trail(n) { ; trail as gesture line
DllCall("SystemParametersInfo", UInt, 0x005D, UInt, n, Str, 0, UInt, 0)
}
DllCall("SystemParametersInfo", UInt, 0x005E, UInt, 0, UIntP, nTrail, UInt, 0) ; get default trail


RLUD(x1,y1,x2,y2) { ; gesture logic
DZ:=33 ; deadzone
If (Abs(x2-x1)>Abs(y2-y1)) {
	If ((x2-x1)>DZ)
		Return 1
	If ((x2-x1)<-DZ)
		Return 2
	}
If ((y2-y1)<-DZ)
	Return 3
If ((y2-y1)>DZ)
	Return 4
}


browser(x1,y1,x2,y2) { ; gestures in chromium, firefox, IE
if !(WinActive("ahk_class Chrome_WidgetWin_1") OR WinActive("ahk_class MozillaWindowClass") OR WinActive("ahk_class IEFrame"))
	Return -1
If ((Abs(x2-x1)>A_ScreenWidth*.62) OR (Abs(y2-y1)>A_ScreenHeight*.62)) ; long-drag
	Switch RLUD(x1,y1,x2,y2) {
		Case 1:
			Send ^{PgDn} ; tab right
		Case 2:
			Send ^{PgUp} ; tab left
		Case 3:
			Send {Home} ; ^{Up} ; scroll home
		Case 4:
			Send {End} ; ^{Down} ; stroll end
		Default:
			Return -1
		}
Else
	Switch RLUD(x1,y1,x2,y2) {
		Case 1:
			Send {Alt down}{Right}{Alt up} ; forward page
		Case 2:
			Send {Alt down}{Left}{Alt up} ; back page
		Case 3:
			Send {PgUp 2} ; scroll down
		Case 4:
			Send {PgDn 2} ; scroll up
		Default:
			Return -1
		}
}


RandL(x1,y1,t1) { ; global rocker gestures
KeyWait, LButton, U
MouseGetPos,x2,y2
Switch RLUD(x1,y1,x2,y2) {
	Case 1:
		Send {Ctrl down}#{Right}{Ctrl up} ; desktop right
	Case 2:
		Send {Ctrl down}#{Left}{Ctrl up} ; desktop left
	Case 3:
		Send #{tab} ; win-tab Menu
	Case 4:
		Send #d ; show desktop
	Default:
		t2:=A_TickCount
		if ((t2-t1) < 300)
			Send {Alt down}{tab}{Alt up} ; alt-tab
		Else
			Send {Ctrl down}{Alt down}{tab}{Alt up}{Ctrl up} ; alt-tab menu
	}
}


RButton::
If (noRclick) {
	noRclick:=0
	Return
	}
t1:=A_TickCount
MouseGetPos,x1,y1
trail(16)
if !GetKeyState("LButton", "P")
	while GetKeyState("RButton", "P")
		if GetKeyState("LButton", "P") {
			RandL(x1,y1,t1)
			Sleep 20
			trail(nTrail)
			Return
			}
trail(nTrail)
If (noRclick) {
	noRclick:=0
	Return
	}
MouseGetPos, x2, y2
If !(browser(x1,y1,x2,y2))
	Return
If (abs(x2-x1)+abs(y2-y1)<22) { ; ignore mini-drag
	Click Right
	Return
	}
MouseMove,%x1%, %y1%, 0 ; preserve default right-click drag
Click, down, right
MouseMove, %x2%, %y2%, 2
Click, up, right
Return


~RButton & LButton::Return ; handle in RButton::


~Rbutton & WheelDown:: ; zoom on R-press
If GetKeyState("RButton", "P") {
	noRclick:=1 
	Send {Ctrl down}{WheelDown}
	sleep 10
	Send {Ctrl up}
	}
Return


~Rbutton & WheelUp:: ; zoom on R-press
If GetKeyState("RButton", "P") {
	noRclick:=1
	Send {Ctrl down}{WheelUp}
	sleep 10
	Send {Ctrl up}
	}
Return


~Rbutton & MButton:: ; zoom reset
noRclick:=1 
Send {Ctrl down}{0}{Ctrl up}
Return