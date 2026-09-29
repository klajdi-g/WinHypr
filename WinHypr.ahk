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

*<+#f23:: ; Copilot key opens Raycast using its default Alt+Space hotkey.
{
    Send "{Blind}{LShift up}{LWin up}" ; Releases the modifiers left stuck by the physical key.
    Send "!{Space}"
}



/* ================ 
 * ===== APPS =====
 * ================ */

#Enter::Run "wt.exe"                     ; Win+Enter: Terminal
#b::Run "https://www.google.com/"       ; Win+B: Opens the Windows default browser.


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

#+t:: ; Win + Shift + T: Toggles "Always on Top" for the active window.
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

; Win + Arrows belong to Windows Snap. Use Win + Alt + H/J/K/L for directional focus.
#!h::FocusAndCenter("Left")
#!l::FocusAndCenter("Right")
#!k::FocusAndCenter("Up")
#!j::FocusAndCenter("Down")

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

; Defines the functions communicating with the DLL.
GetDesktopCount() => DllCall("VirtualDesktopAccessor\GetDesktopCount", "Int")
GoToDesktopNumber(num) => DllCall("VirtualDesktopAccessor\GoToDesktopNumber", "Int", num)
CreateDesktop() => DllCall("VirtualDesktopAccessor\CreateDesktop")
RemoveDesktop(num, fallbackNum) => DllCall("VirtualDesktopAccessor\RemoveDesktop", "Int", num, "Int", fallbackNum, "Int")
GetCurrentDesktopNumber() => DllCall("VirtualDesktopAccessor\GetCurrentDesktopNumber", "Int")
GetWindowDesktopNumber(hWnd) => DllCall("VirtualDesktopAccessor\GetWindowDesktopNumber", "Ptr", hWnd, "Int")
IsWindowOnDesktopNumber(hWnd, num) => DllCall("VirtualDesktopAccessor\IsWindowOnDesktopNumber", "Ptr", hWnd, "Int", num, "Int")
MoveWindowToDesktopNumber(hWnd, num) => DllCall("VirtualDesktopAccessor\MoveWindowToDesktopNumber", "Ptr", hWnd, "Int", num)
IsPinnedWindow(hWnd) => DllCall("VirtualDesktopAccessor\IsPinnedWindow", "Ptr", hWnd, "Int")
IsPinnedApp(hWnd) => DllCall("VirtualDesktopAccessor\IsPinnedApp", "Ptr", hWnd, "Int")

; Creates shortcuts from Win+1 to Win+9 to switch to desktops 1 through 9.
Loop 9 {
    ; Passes A_Index - 1 because the DLL counts desktops starting from 0 (e.g., Desktop 1 = Index 0).
    Hotkey "$#" . A_Index, SwitchToDesktop.Bind(A_Index - 1) ; Use the hook so Windows does not also activate taskbar app 1-9.
}

; Creates shortcuts from Win+Shift+1 to Win+Shift+9 to move the focused window.
Loop 9 {
    Hotkey "$<+#" . A_Index, MoveToDesktop.Bind(A_Index - 1)
}

SwitchToDesktop(targetIndex, *) { ; Handles movement between desktops.
    previousIndex := GetCurrentDesktopNumber()
    currentCount := GetDesktopCount()
    
    while (targetIndex >= currentCount) {
        CreateDesktop() 
        Sleep 50  
        currentCount := GetDesktopCount()
    }
    
    GoToDesktopNumber(targetIndex)
    
    ; Waits for the Windows animation.
    Sleep 200 
    
    ; Windows manages the active window during the switch. Forcing WinActivate
    ; here can make its taskbar button flash during the desktop animation.

    ; Win+9 may create desktops 2-9. Drop unused trailing ones when returning to a lower desktop.
    if (targetIndex < previousIndex)
        TrimEmptyTrailingDesktops()
}

TrimEmptyTrailingDesktops() {
    ; Only remove desktops above the current one: deleting an empty desktop in the
    ; middle would renumber workspaces that still contain windows.
    while (count := GetDesktopCount()) > GetCurrentDesktopNumber() + 1 {
        lastIndex := count - 1
        if DesktopHasWindows(lastIndex)
            break

        if (RemoveDesktop(lastIndex, lastIndex - 1) = -1)
            break
        Sleep 50
        if (GetDesktopCount() >= count)
            break
    }
}

DesktopHasWindows(desktopIndex) {
    ; Windows on other virtual desktops can be hidden/cloaked. WinGetList with
    ; its default hidden-window setting missed them and deleted occupied desktops.
    previousSetting := A_DetectHiddenWindows
    DetectHiddenWindows true
    try {
        for hwnd in WinGetList() {
            winClass := WinGetClass(hwnd)
            if (winClass = "Shell_TrayWnd" || winClass = "Shell_SecondaryTrayWnd" || winClass = "Progman" || winClass = "WorkerW")
                continue
            ; Check every window, including hidden, minimized, and untitled ones.
            windowDesktop := GetWindowDesktopNumber(hwnd)
            if (windowDesktop = desktopIndex || (windowDesktop = -1 && IsWindowOnDesktopNumber(hwnd, desktopIndex) = 1))
                return true
        }
    } catch {
        ; If a window disappears during the scan or the DLL fails, do not delete.
        return true
    } finally {
        DetectHiddenWindows previousSetting
    }
    return false
}

MoveToDesktop(targetIndex, *) { ; Moves only the focused window and follows it.
    sourceIndex := GetCurrentDesktopNumber()
    if (sourceIndex = targetIndex)
        return

    hwnd := WinExist("A")
    if !hwnd || GetWindowDesktopNumber(hwnd) != sourceIndex
        return
    ; A pinned window is already visible on every desktop.
    if (IsPinnedWindow(hwnd) != 0 || IsPinnedApp(hwnd) != 0)
        return

    currentCount := GetDesktopCount()
    while (targetIndex >= currentCount) {
        if (CreateDesktop() = -1)
            return
        Sleep 50
        currentCount := GetDesktopCount()
    }

    if (MoveWindowToDesktopNumber(hwnd, targetIndex) = -1)
        return

    GoToDesktopNumber(targetIndex)
    Sleep 250
    ; Windows brings the destination's window to the foreground itself.
    ; Windows Snap keeps the window's layout on the destination desktop.
    if (targetIndex < sourceIndex)
        TrimEmptyTrailingDesktops()
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
        RemoveDesktop(currentIndex, targetIndex)
        
        ; Let Windows restore focus without flashing a taskbar button.
    }
}
