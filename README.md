# Project Mach ✈️

**Project Mach** is a high-fidelity, open-source arcade jet fighter game built with **Godot 4.6**. It features a custom physics-based flight model, intense dogfighting combat, and a scalable architecture designed to run smoothly on both High-End PC and Mobile (Android) devices.

![Godot 4](https://img.shields.io/badge/Godot-v4.6-%23478cbf)
![License](https://img.shields.io/badge/License-MIT-green)

## 🌟 Key Features

### ✈️ Flight Mechanics
*   **Physics-Based Flight**: Uses `RigidBody3D` with a custom force integrator for realistic momentum and energy management.
*   **Data-Driven Jets**: Flight characteristics (Turn Rate, Acceleration, Drag) are defined in `JetConfig` resources (`.tres`), allowing for easy balancing.
*   **Dynamic Camera**: Chase camera with speed-based FOV scaling, look-ahead smoothing, and G-force screen shake.

### ⚔️ Combat System
*   **Missile Guidance**: Implementation of **Proportional Navigation (PN)** logic for realistic missile intercepts. Includes fuel timers, acceleration phases, and "Distraction" logic for Flares.
*   **Machine Gun**: Raycast-based ballistics with **"Magnetism" Aim Assist** to help players hit targets on smaller screens.
*   **Enemy AI**: A Throttled State Machine (10Hz) handling Patrol, Acquire, Chase, and Evade behaviors.
*   **Countermeasures**: Deployable Flares that act as high-heat decoys for incoming missiles.

### 🌍 Environment & Performance
*   **Terrain Streaming**: A chunking system that manages 512m grid squares, seamlessly loading/unloading checks around the player.
*   **Mobile Optimization**:
    *   **PlatformManager**: Auto-detects OS (Android vs Windows) and adjusts rendering quality (MSAA, Shader Quality) on boot.
    *   **Throttled Logic**: AI and HUD updates run at 10-15Hz to free up CPU time on mobile.
    *   **Shader Pre-compilation**: Includes a warmup system to prevent shader stutter on Android.

---

## 🎮 Controls

The game supports both **Keyboard/Mouse** and **Gamepad**.

| Action | Keyboard | Gamepad |
| :--- | :--- | :--- |
| **Pitch** | `W` / `S` | Left Stick Y |
| **Roll** | `A` / `D` | Left Stick X |
| **Yaw** | `Q` / `E` | LB / RB |
| **Throttle** | `Shift` (Up) / `Ctrl` (Down) | Triggers (RT/LT) |
| **Fire Gun** | `Space` | Button A (Xbox) / Cross (PS) |
| **Fire Missile** | `Alt` | Button B (Xbox) / Circle (PS) |
| **Pause** | `Esc` | Start |

> **Note**: On Mobile (Android), a Virtual Joystick will automatically appear on screen.

---

## 🛠️ Installation & Setup

### Prerequisites
*   **Godot Engine v4.6** (Standard Version). [Download Here](https://godotengine.org/download).

### Getting Started
1.  **Clone the Repository**:
    ```bash
    git clone https://github.com/nizarsyed/Project-Mach.git
    ```
2.  **Open in Godot**:
    *   Launch Godot.
    *   Click **Import**.
    *   Navigate to the cloned folder and select `project.godot`.
    *   Click **Import & Edit**.
3.  **Run the Game**:
    *   Press **F5** (or click the Play button) to launch the main scene (`test_level.tscn`).

---

## 🚀 Deployment

### Windows / PC
1.  Go to **Project** -> **Export**.
2.  Click **Add...** -> **Windows Desktop**.
3.  (Optional) Uncheck "Debug" for a release build.
4.  Click **Export Project...** and choose a destination folder.
5.  Run the generated `.exe`.

### Android
1.  **Setup**: ensure you have Android Studio / SDK Command Line Tools installed and configured in Editor Settings -> Export -> Android.
2.  Go to **Project** -> **Export**.
3.  Click **Add...** -> **Android**.
4.  **Architectures**: Check `arm64-v8a` (standard for modern phones).
5.  **Texture Format**: Ensure `ETC2 / ASTC` is supported (Standard in Godot 4).
6.  Click **Export Project...** to generate an `.apk`.
7.  **Install**: `adb install ProjectMach.apk`.

---

## 📂 Project Structure

```
res://
├── _core/                  # Core Systems (Singletons, Managers, Configs)
│   ├── platform_manager.gd
│   ├── input_manager.gd
│   ├── mission_manager.gd
│   └── ...
├── components/             # Reusable Component Scripts
│   ├── flight/             # Physics, Camera, AI
│   ├── combat/             # Machine Gun logic
│   └── terrain/            # Streaming logic
├── entities/               # Game Object Scenes (.tscn)
│   ├── aircraft/           # Player & Enemy Jets
│   └── weapons/            # Missiles, Flares
├── levels/                 # Game Levels
├── ui/                     # User Interface
└── assets/                 # (Place your Models/Textures here)
```

## 🤝 Contributing
Contributions are welcome! Please fork the repository and submit a Pull Request.

## 📄 License
This project is licensed under the **MIT License**.
