# 🚀 Flatpacker — Offline Flatpak Bundler

> **Turn any installed Flatpak into a fully offline `.flatpak` bundle**  
> One script. No internet required after bundling. Put your .flatpak on folder with script.

![made-with-bash](https://img.shields.io/badge/Made%20with-Bash-1f425f.svg)
![flatpak](https://img.shields.io/badge/Flatpak-✓-4caf50)
![version](https://img.shields.io/badge/version-2.0-blue)

---

## ✨ What It Does

- 📦 **Packages** installed Flatpak apps into `.flatpak` bundles  
- 🧠 **Auto-detects** dependencies (runtime / SDK)  
- 💾 **Generates a complete offline installer** with `install.sh`  
- 📁 **Safe** — doesn't touch your current setup  
- ⚡ Works on **old systems** (Fedora 29 / Flatpak 1.0.3 minimum)

---

## 🎬 Live Demo

```bash
$ ./flatpacker.sh

════════════════════════════════════════════════════════════
    📦 Flatpak Bundle Builder — Full Version
════════════════════════════════════════════════════════════

📱 Installed apps:
   1) com.bilingify.readest/x86_64/stable
   2) io.github.tanaybhomia.Whisp/x86_64/stable


>all

✅ Selected 4 packages

🔨 Creating bundles...
  📦 Processing: org.gnome.Platform (50) [runtime]
  ✅ Done: runtime-org.gnome.Platform-x86_64-50.flatpak (285 MB)

  📦 Processing: com.bilingify.readest (stable) [app]
  ✅ Done: app-com.bilingify.readest-x86_64-stable.flatpak (36 MB)

✨ Done! Bundles are in: flatpak-bundles-20250616-010049

✅ Installer created: install.sh
