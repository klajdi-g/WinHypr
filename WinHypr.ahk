/* ================================
 * ===== HEADER AND LIBRARIES ===== 
 * ================================ */

#Requires AutoHotkey v2.0
#SingleInstance Force

; Loads the VirtualDesktopAccessor DLL into memory.
dllPath := A_ScriptDir . "\VirtualDesktopAccessor.dll"
hVDA := DllCall("LoadLibrary", "Str", dllPath, "Ptr")

if !hVDA {
    MsgBox "Error: VirtualDesktopAccessor.dll not found in the script folder!"
    ExitApp
}


/* =================== 
 * ===== GLOBALS ===== 
 * =================== */

*<+#f23:: ; Copilot key opens Flow Launcher.
{
    Send "{Blind}{LShift up}{LWin up}" ; Releases the modifiers left stuck by the physical key.
    Send "^+!f"                        ; Sends Ctrl+Shift+Alt+F (Ensure this is set in Flow Launcher!).
}


/* ================ 
 * ===== APPS =====
 * ================ */

#Enter::run "wt.exe"     ; Win+Enter: Terminal
#b::run "zen.exe"        ; Win+B: Browser
#c::run "codium.exe"     ; Win+C: VSCodium


/* ============================= 
 * ===== WINDOW MANAGEMENT =====
 * ============================= */

#q:: ; Win+Q: Closes the active window.
{
    if WinExist("A")
        WinClose "A"
}

#m:: ; Win+M: Minimizes the active window.
{
    if WinExist("A")
        WinMinimize "A"
}

#f:: ; Win+F: Toggles between Maximize and Restore.
{
    if WinExist("A") {
        if WinGetMinMax("A") == 1
            WinRestore "A"
        else
            WinMaximize "A"
    }
}

#t:: ; Win+T: Toggles the transparency of the active window.
{
    if WinExist("A") {
        transp := WinGetTransparent("A")
        if (transp = "" || transp = 255)
            WinSetTransparent(210, "A") ; 210 is the opacity level (0-255).
        else
            WinSetTransparent("Off", "A")
    }
}

!Space:: ; Alt + Space: Toggles "Always on Top" for the active window.
{
    if WinExist("A") {
        WinSetAlwaysOnTop -1, "A"
    }
}

#!c:: ; Win + Alt + C: Centers the active window on the screen.
{
    activeHwnd := WinExist("A")
    if !activeHwnd
        return
        
    ; Gets the work area of the primary monitor (excluding the taskbar).
    MonitorGetWorkArea(MonitorGetPrimary(), &WL, &WT, &WR, &WB)
    workW := WR - WL
    workH := WB - WT
    
    WinGetPos ,, &winW, &winH, activeHwnd
    
    ; Calculates the exact center coordinates.
    newX := WL + (workW - winW) / 2
    newY := WT + (workH - winH) / 2
    
    ; Removes delay for instant snapping.
    SetWinDelay -1
    WinMove newX, newY,,, activeHwnd
}

!LButton:: ; Alt + Left Click: Drags the window from anywhere.
{
    SetWinDelay -1 ; Removes AutoHotkey's default 100ms delay.
    CoordMode "Mouse", "Screen" ; Uses absolute screen coordinates.
    MouseGetPos &startX, &startY, &hwnd
    
    if !hwnd
        return
        
    WinActivate "ahk_id " hwnd
    WinGetPos &winX, &winY,,, "ahk_id " hwnd
    
    ; Calculates the mouse displacement while the button is held down.
    while GetKeyState("LButton", "P") {
        MouseGetPos &currentX, &currentY
        WinMove winX + (currentX - startX), winY + (currentY - startY),,, "ahk_id " hwnd
        Sleep 10
    }
}

; Win + Alt + Arrows: Resizes the active window.
#!Right::ResizeWindow("Right")
#!Left::ResizeWindow("Left")
#!Down::ResizeWindow("Down")
#!Up::ResizeWindow("Up")

ResizeWindow(direction) {
    step := 50 ; Number of pixels to add or remove on each press.
    
    activeHwnd := WinExist("A")
    if !activeHwnd
        return
        
    WinGetPos &x, &y, &w, &h, activeHwnd
    
    ; Disables the delay to make resizing immediate and smooth.
    SetWinDelay -1
    
    ; Sends the "start resize" signal to prevent graphical glitches.
    SendMessage 0x0231, 0, 0,, activeHwnd 

    if (direction = "Right")
        w += step  ; Widens.
    else if (direction = "Left")
        w -= step  ; Narrows.
    else if (direction = "Down")
        h += step  ; Lengthens downwards.
    else if (direction = "Up")
        h -= step  ; Shortens upwards.
        
    WinMove x, y, w, h, activeHwnd
    
    ; Sends the "end resize" signal.
    SendMessage 0x0232, 0, 0,, activeHwnd 
}

; Disables Win + Shift + Up/Down (Native vertical maximization).
#+Up::return
#+Down::return

; Win + Arrows: Changes focus to the window on the Right/Left/Up/Down and centers the mouse.
$#Left::FocusAndCenter("Left")
$#Right::FocusAndCenter("Right")
$#Up::FocusAndCenter("Up")
$#Down::FocusAndCenter("Down")

FocusAndCenter(direction) {
    activeHwnd := WinExist("A")
    if !activeHwnd
        return
    
    WinGetPos &ax, &ay, &aw, &ah, activeHwnd
    acx := ax + aw/2  ; X center of the active window.
    acy := ay + ah/2  ; Y center of the active window.
    
    targetHwnd := 0
    minDist := 999999
    
    for hwnd in WinGetList(,, "Program Manager") {
        ; Ignores the already active window and hidden windows.
        if (hwnd = activeHwnd) || !(WinGetStyle(hwnd) & 0x10000000) 
            continue
            
        ; FILTER: Ignores the Taskbar, Desktop, and untitled system processes.
        winClass := WinGetClass(hwnd)
        if (winClass = "Shell_TrayWnd" || winClass = "Shell_SecondaryTrayWnd" || winClass = "Progman" || winClass = "WorkerW" || WinGetTitle(hwnd) = "")
            continue

        WinGetPos &wx, &wy, &ww, &wh, hwnd
        wcx := wx + ww/2 
        wcy := wy + wh/2 
        
        isValid := false
        
        ; Checks if the window is in the correct direction.
        if (direction = "Left" && wcx < acx)
            isValid := true
        else if (direction = "Right" && wcx > acx)
            isValid := true
        else if (direction = "Up" && wcy < acy)
            isValid := true
        else if (direction = "Down" && wcy > acy)
            isValid := true

        ; If it is in the correct direction, calculates the real distance (Pythagorean theorem) to find the closest one.
        if isValid {
            dist := Sqrt((wcx - acx)**2 + (wcy - acy)**2)
            if (dist < minDist) {
                minDist := dist
                targetHwnd := hwnd
            }
        }
    }
    
    if targetHwnd {
        WinActivate targetHwnd
        WinGetPos ,, &tw, &th, targetHwnd
        CoordMode "Mouse", "Window"
        MouseMove tw/2, th/2, 0 
    }
}


/* ==============================
 * ===== DESKTOP MANAGEMENT ===== 
 * ============================== */

; Disables Ctrl + Win + Right/Left (Native Windows desktop switching).
#^Left::return
#^Right::return

; Defines the functions communicating with the DLL.
GetDesktopCount() => DllCall("VirtualDesktopAccessor\GetDesktopCount", "Int")
GoToDesktopNumber(num) => DllCall("VirtualDesktopAccessor\GoToDesktopNumber", "Int", num)
CreateDesktop() => DllCall("VirtualDesktopAccessor\CreateDesktop")
RemoveDesktop(num) => DllCall("VirtualDesktopAccessor\RemoveDesktop", "Int", num)
GetCurrentDesktopNumber() => DllCall("VirtualDesktopAccessor\GetCurrentDesktopNumber", "Int")
MoveWindowToDesktopNumber(hWnd, num) => DllCall("VirtualDesktopAccessor\MoveWindowToDesktopNumber", "Ptr", hWnd, "Int", num)
IsWindowOnCurrentVirtualDesktop(hWnd) => DllCall("VirtualDesktopAccessor\IsWindowOnCurrentVirtualDesktop", "Ptr", hWnd, "Int")

; Creates shortcuts from Win+1 to Win+9 to switch to desktops 1 through 9.
Loop 9 {
    ; Passes A_Index - 1 because the DLL counts desktops starting from 0 (e.g., Desktop 1 = Index 0).
    Hotkey "#" . A_Index, SwitchToDesktop.Bind(A_Index - 1) ; A_Index represents the current iteration value.
}

; Creates shortcuts from Win+1 to Win+9 to move windows to desktops 1 through 9.
Loop 9 {
    Hotkey "<+#" . A_Index, MoveToDesktop.Bind(A_Index - 1)
}

SwitchToDesktop(targetIndex, *) { ; Handles movement between desktops.
    currentCount := GetDesktopCount()
    
    while (targetIndex >= currentCount) {
        CreateDesktop() 
        Sleep 50  
        currentCount := GetDesktopCount()
    }
    
    GoToDesktopNumber(targetIndex)
    
    ; Waits for the Windows animation.
    Sleep 200 
    
    ; Calls the function to activate the foreground app.
    FocusTopWindow()
}

MoveToDesktop(targetIndex, *) { ; Moves the window and follows it to the new desktop.
    hwnd := WinExist("A")
    if hwnd {
        currentCount := GetDesktopCount()
        while (targetIndex >= currentCount) {
            CreateDesktop()
            Sleep 50 
            currentCount := GetDesktopCount()
        }
        
        WinMinimize "ahk_id " hwnd
        Sleep 50
        MoveWindowToDesktopNumber(hwnd, targetIndex)
        GoToDesktopNumber(targetIndex) 
        Sleep 250
        WinRestore "ahk_id " hwnd
        
        FocusTopWindow() ; Restores focus cleanly here as well.
    }
}

FocusTopWindow() { ; Focus function
    ; WinGetList returns windows in order from most recent to oldest.
    for hwnd in WinGetList() {
        ; Ignores invisible and system-hidden windows.
        if !(WinGetStyle(hwnd) & 0x10000000) 
            continue
            
        ; Filter to ignore the taskbar, backgrounds, and empty processes.
        winClass := WinGetClass(hwnd)
        if (winClass = "Shell_TrayWnd" || winClass = "Shell_SecondaryTrayWnd" || winClass = "Progman" || winClass = "WorkerW" || WinGetTitle(hwnd) = "")
            continue
            
        ; Checks if this window is located on the current desktop.
        if IsWindowOnCurrentVirtualDesktop(hwnd) {
            ; Found! Being the first in the list, it is the last one used.
            WinActivate hwnd
            
            ; Moves the mouse exactly to the center of this window.
            WinGetPos ,, &tw, &th, hwnd
            CoordMode "Mouse", "Window"
            MouseMove tw/2, th/2, 0 
            
            ; Sends an empty Esc to close the taskbar if it is set to auto-hide.
            Send "{Esc}" 
            return ; Exits the function; the operation is complete.
        }
    }
    
    ; If execution reaches this point, the desktop is COMPLETELY EMPTY.
    ; Clicks empty screen space to remove focus from nothingness and hide the taskbar.
    CoordMode "Mouse", "Screen"
    MouseGetPos &mx, &my
    MouseClick "Left", 1, 1, 1, 0
    MouseMove mx, my, 0
}

/* --- Desktop Deletion Management ---
 * Windows does not automatically delete empty desktops, so this edge case is handled
 * via user input. Manually deleting desktops requires too many steps, so the Win+Backspace 
 * shortcut was created to delete the current desktop and move the user to the previous one.
 * The only undeletable desktop is the first one, which MUST exist!
 */
#Backspace::
{
    currentIndex := GetCurrentDesktopNumber()
    currentCount := GetDesktopCount()
    
    ; Does nothing if there is only one desktop.
    if (currentCount <= 1) {
        return
    }

    if (currentIndex > 0) {
        ; Calculates the index of the previous desktop if not on the first one.
        targetIndex := currentIndex - 1
        
        ; Moves the user to the previous desktop.
        GoToDesktopNumber(targetIndex)
        
        ; Waits a moment for Windows to perform the switch.
        Sleep 100
        
        ; Deletes the desktop at currentIndex, which was the one before the switch.
        RemoveDesktop(currentIndex)
        
        ; Forces focus on the active window of the new desktop.
        if WinExist("A")
            WinActivate "A"
    }
}