# WinHypr 🚀

**WinHypr** is a lightweight, compiled AutoHotkey v2 script for workspace and window shortcuts on Windows 11. It uses Windows Snap for window layouts rather than drawing its own tiles.

It overrides clunky native Windows behaviors to give you lightning-fast workspace management, directional window focus, seamless window dragging, and advanced shortcuts, turning your Windows machine into a power user's dream.


## Key Features
* **Hyprland-Style Workspaces:** Instantly jump to specific virtual desktops or send windows to them without using the mouse.
* **Smart Directional Focus:** `Win + Alt + H/J/K/L` switches focus between windows and centers the pointer on the selected app.
* **Linux-Style Window Dragging:** Hold `Alt` and `Left Click` anywhere inside a window to drag it—no need to aim for the title bar!
* **Keyboard-Driven Resizing:** Resize windows dynamically using keyboard shortcuts.
* **Clean Taskbar Integration:** Workspace number shortcuts use the keyboard hook to avoid triggering Windows' pinned-taskbar-app shortcuts. Switching desktops does not force-activate windows or send Esc during the animation.
* **Cursor-Stable Desktop Switching:** Workspace shortcuts leave the mouse where it is, including when the destination desktop is empty. Directional window focus still centers the pointer on the selected window.
* **Empty Workspace Cleanup:** Switching back to a lower-numbered desktop removes unused trailing desktops (for example, an empty Desktop 9 and the empty desktops created on the way there). Desktops containing windows are kept; empty desktops in the middle are not removed, so occupied workspace numbers stay stable.
  Cleanup checks windows on other virtual desktops even when Windows hides them; if a check fails, the desktop is left in place rather than moving its windows to another desktop.
* **Native Windows Snap:** `Win + Left/Right` snaps a focused window to half the screen, and `Win + Z` opens Snap Layouts. Windows controls the actual borders and gaps. WinHypr no longer repositions windows automatically or touches fullscreen windows.


## Prerequisites & Requirements

* **OS:** Designed and tested for **Windows 11 (64-bit)**. (Windows 10 may not fully support the specific VirtualDesktopAccessor implementation).
* **Raycast (optional):** The Copilot key sends `Alt + Space`, the default [Raycast for Windows](https://www.raycast.com/windows) hotkey. Set Raycast's hotkey to `Alt + Space` in Raycast Settings > General if you changed it. If you don't use Raycast, `Alt + Space` retains its normal Windows behavior.
* **App launchers:** `Win + Enter` requires Windows Terminal (`wt.exe`). `Win + B` opens `https://www.google.com/` in your Windows default browser, rather than requiring Zen. To use a different home page or a specific browser, change the URL in the `#b::Run` line of `WinHypr.ahk` to a URL or executable (for example, `"zen.exe"`).


## Installation

Download or clone this repository and double-click `WinHypr.exe`. Keep `VirtualDesktopAccessor.dll` in the **same folder** as the executable. AutoHotkey is not required for the compiled build. To edit and run the source instead, install [AutoHotkey v2](https://www.autohotkey.com/) and run `WinHypr.ahk`. If you edit the script, recompile it to update the EXE. Releases from the original upstream repository do **not** include these changes.

> **Run at Startup:** To start WinHypr automatically when you boot your PC:
> 1. Right-click `WinHypr.exe` -> Create Shortcut.
> 2. Press `Win + R`, type `shell:startup`, and press Enter.
> 3. Move the shortcut into the Startup folder.


## Shortcuts Reference

### Global & App Launchers
| Shortcut | Action |
| :--- | :--- |
| `Copilot Key` | Sends `Alt + Space` (opens Raycast with its default hotkey) |
| `Win + Enter` | Opens Terminal (`wt.exe`) |
| `Win + B` | Opens your default browser at the configured URL |

### Window Management
| Shortcut | Action |
| :--- | :--- |
| `Win + Q` | Close the active window |
| `Win + M` | Minimize the active window |
| `Win + F` | Toggle Maximize / Restore |
| `Win + T` | Toggle window transparency |
| `Win + Shift + T` | Toggle "Always on Top" for the active window |
| `Win + Alt + C` | Center the active window on the screen |
| `Alt + Left Click` | Drag window from anywhere |
| `Win + Alt + Arrows`| Resize the active window (50px steps) |
| `Win + Arrows` | Windows Snap / maximize / restore (native Windows shortcut) |
| `Win + Z` | Open Windows Snap Layouts |
| `Win + Alt + H/J/K/L` | Focus window Left/Down/Up/Right |

### Virtual Desktops (Workspaces)
| Shortcut | Action |
| :--- | :--- |
| `Win + 1..9` | Switch directly to Desktop 1-9 |
| `Win + Shift + 1..9`| Move only the focused window to Desktop 1-9 and follow it |
| `Win + Backspace` | Delete the current desktop and shift focus to the left |

Switching from `Win + 9` back to `Win + 1` removes empty desktops at the end of the list. A desktop with an open or minimized window is not removed.
For example, `Win + Shift + 3` moves only the focused window to Desktop 3 and switches there. Other windows stay where they are. Pinned windows/apps are not moved. For two side-by-side windows, focus the first and press `Win + Left`, then choose the second window from Windows Snap Assist (or focus it and press `Win + Right`). This uses Windows' native frame spacing; automatically arranging new windows without activating them is not provided by Windows Snap.


## Building from Source
If you want to modify the script:
1. Download and install [AutoHotkey v2](https://www.autohotkey.com/).
2. Clone this repository.
3. Open `WinHypr.ahk` with your favorite text editor to make changes.
4. Run the script directly or compile it using `Ahk2Exe`.


## Credits
* Desktop management is powered by the amazing [VirtualDesktopAccessor](https://github.com/Ciantic/VirtualDesktopAccessor) DLL.
