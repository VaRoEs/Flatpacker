# 🚀 Flatpacker — Offline Flatpak Bundler

> **Turn any installed Flatpak into a fully offline `.flatpak` bundle**  
> *One script. No internet required after bundling.*

[![made-with-bash](https://img.shields.io/badge/Made%20with-Bash-1f425f.svg)](https://www.gnu.org/software/bash/)
[![Flatpak](https://img.shields.io/badge/Flatpak-✓-4caf50)](https://flatpak.org/)
[![Version](https://img.shields.io/badge/version-2.0-blue)](https://github.com/yourusername/flatpacker)
[![License](https://img.shields.io/badge/license-MIT-green)](LICENSE)

---

## 📖 Table of Contents

- [✨ What It Does](#-what-it-does)
- [🎬 Live Demo](#-live-demo)
- [🚀 Quick Start](#-quick-start)
- [📦 Usage](#-usage)
- [🛠️ Requirements](#️-requirements)
- [🐛 Troubleshooting](#-troubleshooting)
- [📄 License](#-license)

---

## ✨ What It Does

| Feature | Description |
|---------|-------------|
| 📦 **Packages** | Convert installed Flatpak apps into `.flatpak` bundles |
| 🧠 **Auto-detects** | Finds dependencies (runtime / SDK) automatically |
| 💾 **Offline installer** | Generates a complete `install.sh` script |
| 📁 **Safe** | Doesn't touch your current Flatpak setup |
| ⚡ **Legacy support** | Works on Fedora 29+ (Flatpak 1.0.3 minimum) |

---

## 🎬 Live Demo

### 📸 Screenshots

| Step | Screenshot |
|------|------------|
| **Building bundles** | <img width="740" alt="build" src="https://github.com/user-attachments/assets/5ca1e0d3-5f27-4cb1-8976-6a4167150023" /> |
| **Bundle created** | <img width="791" alt="bundle" src="https://github.com/user-attachments/assets/03737436-ae12-47dc-9369-d61a585ce3d2" /> |
| **Success message** | <img width="881" alt="success" src="https://github.com/user-attachments/assets/816cd70f-8b4d-4b67-98e3-0a82feaf6bee" /> |

> 🎉 *"Wow! Flatpaks built!"*

### 🔄 Installation Demo

| Before | After |
|--------|-------|
| <img width="1255" alt="before" src="https://github.com/user-attachments/assets/72b59309-50d8-4f85-a033-553a5237ac5b" /> | <img width="1262" alt="after" src="https://github.com/user-attachments/assets/7ca652e1-02ef-43a1-81d7-053c515db74d" /> |

**Running `install.sh`:**  
<img width="804" alt="install" src="https://github.com/user-attachments/assets/d2ec036c-beb7-422b-8c2b-f759831a77d9" />

### 🐧 Legacy Support (Fedora 29)

> *"In Fedora 29 (Flatpak 1.0.3) you can install bundles — building not supported, but installation works perfectly!"*

<img width="514" alt="legacy1" src="https://github.com/user-attachments/assets/242ab394-db90-4184-b619-2fff7268adc0" />
<img width="816" alt="legacy2" src="https://github.com/user-attachments/assets/862448b0-9b39-41c0-9add-d8ea60f62ccd" />
<img width="1692" alt="legacy3" src="https://github.com/user-attachments/assets/a171f6d3-3130-4cad-8fb5-6a616a69c27e" />

---

## 🚀 Quick Start

### 1️⃣ Clone or Download
```bash
git clone https://github.com/yourusername/flatpacker.git
cd flatpacker
