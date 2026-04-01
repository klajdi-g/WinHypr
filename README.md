# WinHypr 🚀

**WinHypr** is a lightweight, compiled AutoHotkey v2 script that brings the dynamic tiling window manager experience (inspired by Linux's Hyprland) to Windows 11. 

It overrides clunky native Windows behaviors to give you lightning-fast workspace management, directional window focus, seamless window dragging, and advanced shortcuts, turning your Windows machine into a power user's dream.


## Key Features
* **Hyprland-Style Workspaces:** Instantly jump to specific virtual desktops or send windows to them without using the mouse.
* **Smart Directional Focus:** Switch focus between windows using directional keys, automatically centering your mouse cursor on the newly focused app.
* **Linux-Style Window Dragging:** Hold `Alt` and `Left Click` anywhere inside a window to drag it—no need to aim for the title bar!
* **Keyboard-Driven Resizing:** Resize windows dynamically using keyboard shortcuts.
* **Clean Taskbar Integration:** Custom logic prevents the Windows 11 taskbar from glitching or popping up unnecessarily during workspace transitions.


## Prerequisites & Requirements

* **OS:** Designed and tested for **Windows 11 (64-bit)**. (Windows 10 may not fully support the specific VirtualDesktopAccessor implementation).
* **Flow Launcher:** The Copilot key shortcut is built to trigger [Flow Launcher](https://www.flowlauncher.com/). For this to work, you **must** open Flow Launcher's settings and change its activation hotkey to `Ctrl + Shift + Alt + F`.
* **Third-Party Apps:** The app launcher section (`Win + B`, `Win + C`, etc.) uses specific executable names. If you don't use these apps, those specific shortcuts will throw an error (or you can build from source and change them to match your preferred apps):
  * `wt.exe` (Windows Terminal - built-in)
  * `zen.exe` (Zen Browser)
  * `codium.exe` (VSCodium)


## Installation

You don't need to install AutoHotkey to use WinHypr. 

1. Go to the **[Releases](../../releases)** tab and download the latest `.zip` file.
2. Extract the folder to a location of your choice.
3. **CRITICAL:** Ensure that `VirtualDesktopAccessor.dll` and `WinHypr.exe` are in the **same folder**.
4. Double-click `WinHypr.exe` to run it.

> **Run at Startup:** To start WinHypr automatically when you boot your PC:
> 1. Right-click `WinHypr.exe` -> Create Shortcut.
> 2. Press `Win + R`, type `shell:startup`, and press Enter.
> 3. Move the shortcut into the Startup folder.


## Shortcuts Reference

### Global & App Launchers
| Shortcut | Action |
| :--- | :--- |
| `Copilot Key` | Opens Flow Launcher (Maps to `Ctrl+Shift+Alt+F`) |
| `Win + Enter` | Opens Terminal (`wt.exe`) |
| `Win + B` | Opens Browser (`zen.exe`) |
| `Win + C` | Opens VSCodium (`codium.exe`) |

### Window Management
| Shortcut | Action |
| :--- | :--- |
| `Win + Q` | Close the active window |
| `Win + M` | Minimize the active window |
| `Win + F` | Toggle Maximize / Restore |
| `Win + T` | Toggle window transparency |
| `Alt + Space` | Toggle "Always on Top" for the active window |
| `Win + Alt + C` | Center the active window on the screen |
| `Alt + Left Click` | Drag window from anywhere |
| `Win + Alt + Arrows`| Resize the active window (50px steps) |
| `Win + Arrows` | Smart Focus: switch focus to Left/Right/Up/Down |

### Virtual Desktops (Workspaces)
| Shortcut | Action |
| :--- | :--- |
| `Win + 1..9` | Switch directly to Desktop 1-9 |
| `Win + Shift + 1..9`| Move the active window to Desktop 1-9 and follow it |
| `Win + Backspace` | Delete the current desktop and shift focus to the left |


## Building from Source
If you want to modify the script:
1. Download and install [AutoHotkey v2](https://www.autohotkey.com/).
2. Clone this repository.
3. Open `WinHypr.ahk` with your favorite text editor to make changes.
4. Run the script directly or compile it using `Ahk2Exe`.


## Credits
* Desktop management is powered by the amazing [VirtualDesktopAccessor](https://github.com/Ciantic/VirtualDesktopAccessor) DLL.
