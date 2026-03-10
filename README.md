# JCM (Just a Clipboard Manager) 📎✨

A modern, aesthetic, and lightweight clipboard manager for **Wayland**, built with Python, Quickshell, and a pure "Vibecoding" spirit.

> [!NOTE]
> This is a **Vibecoding** project—built iteratively through AI collaboration to prioritize UX, speed, and a premium aesthetic.

![Aesthetic Preview Light mode](https://github.com/justanoobcoder/jcm/blob/main/img/1.png?raw=true)
![Aesthetic Preview Dark mode](https://github.com/justanoobcoder/jcm/blob/main/img/2.png?raw=true)

## ✨ Features

- **Modern Aesthetic**: Windows 11-inspired design, glassmorphism hints, and buttery smooth transitions.
- **Smart Detection**:
  - **Colors**: Automatically detects Hex and RGB/RGBA codes and shows a live preview box.
  - **Links**: Detects URLs and provides an "Open in Browser" action directly.
- **Vim-like Navigation**: Fast, keyboard-driven history management.
- **Image Support**: Captures and previews images with aspect-ratio awareness.
- **Persistence**: Powered by SQLite for reliable history storage.
- **Filtering & Search**: Quickly find clips by text content or category (All, Text, Image, Color, Link).
- **Auto-Cleanup**: Optional "Auto-delete on reboot" to keep your daily history fresh while preserving your **pinned** items.

## 🛠️ Dependencies

To run JCM, you need the following tools installed on your system:

- **Quickshell**: The UI engine (rendering the `.qml` files).
- **Python 3**: Runs the background daemon.
- **wl-clipboard**: For interacting with the Wayland clipboard.
- **wtype**: For the "Paste Right Away" simulation.
- **xdg-utils**: For opening links in your default browser.

## 🚀 How to Run

### 🛠️ Manual Installation (Other Linux Distros)

1. **Clone the repository**:
   ```bash
   git clone https://github.com/justanoobcoder/jcm.git
   cd jcm
   ```

2. **Launch the app**:
   ```bash
   ./bin/jcm
   ```
   *The script will automatically spawn the background daemon if it's not already running.*

3. **System-wide Installation (Optional)**:
   To install JCM globally so you can launch it from anywhere, run:
   ```bash
   sudo make install
   ```
   This will place the executables in `/usr/bin/` and the QML files in `/usr/share/jcm/`.

4. **Autostart the Daemon**:
   JCM runs a background watcher. To ensure it captures your clipboard continuously, add the following command to your Desktop Environment's autostart script (like `~/.config/sway/config` or `~/.config/hypr/hyprland.conf`):
   ```bash
   jcm-daemon watch &
   ```

---

### ❄️ NixOS Installation (Flakes + Home Manager)

If you are using NixOS with Flakes and Home Manager, JCM provides a native module and derivation.

1. **Add to your `flake.nix` inputs**:
   ```nix
   {
     inputs.jcm.url = "github:justanoobcoder/jcm";
   }
   ```

2. **Import and enable in your Home Manager configuration**:
   ```nix
   { inputs, ... }:
   {
     imports = [ inputs.jcm.homeManagerModules.default ];
     programs.jcm.enable = true;
   }
   ```

This will automatically install the binaries and enable a background `jcm.service` that starts when your graphical session is ready! 🚀

## ⌨️ Keybinds

| Key | Action |
| :--- | :--- |
| `j` | Move Selection Down |
| `k` | Move Selection Up |
| `d` | **Delete** Selected Item |
| `Enter` | **Copy** Selected Item (and paste if enabled) |
| `/` | **Focus** Search Bar |
| `Esc` | Return to list (if searching) / **Close App** |
| `q` | **Close App** (if not typing in search) |

## 🎨 Category Filters

Use the dropdown in the header to filter by:
- **All**: Your entire history.
- **Text**: Pure text snippets.
- **Image**: Visual captures.
- **Color**: Hex/RGB codes only.
- **Link**: Web addresses only.

## ⚙️ Configuration

Toggle these via the gear icon in the app:
- **Dark Mode**: Switch between light and dark aesthetics.
- **Auto Delete**: Automatically clear unpinned history on reboot.
- **Paste Right Away**: Instantly paste clips into your active window when selected.

---
*Built with ❤️ for the Wayland ecosystem.*
