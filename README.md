# 无人机平台

> **Current Status:** ✅ v1.1.0 Completed — LiDAR-Inertial Localization & Waypoint Navigation Verified  
> **Latest Version:** v1.1.0

## 📖 Introduction
This repository documents the iterative development of a custom **250mm wheelbase quadrotor** designed for advanced autonomous navigation and control research. 

The goal is to build a robust hardware and software foundation, starting from classical SLAM and planning algorithms, and gradually migrating towards **Deep Reinforcement Learning (DRL)** based perception and control systems.

## 🛠️ Hardware Platform
The drone is built on a custom 250mm carbon fiber frame, featuring a high-performance compute module for onboard AI processing.

| Component | Model / Specs | Note |
| :--- | :--- | :--- |
| **Onboard Computer** | **NVIDIA Jetson Orin NX (8GB)** | Core computing unit |
| **Flight Controller**| **Holybro Pixhawk 4** | 32-bit, running PX4/ArduPilot |
| **LiDAR** | **Livox Mid-360** | Omnidirectional 3D LiDAR |
| **Depth Camera** | **Intel RealSense D435** | For VIO and depth sensing |
| **Frame** | **Custom Carbon Fiber (250mm)** | "Taobao" Custom Cut |
| **Motors** | **Koofly 2207 V2 (1960KV)** | 4S Power System |
| **ESC** | **EMAX BLHeli32 (45A)** | 4-in-1 ESC supported |
| **Battery** | **Gens Ace 4S 4000mAh** | Long endurance for computing |
| **Propellers** | **Gemfan 5147 (3-blade)** | Efficient 5-inch props |
| **RC System** | **RadioLink AT9S Pro + R12DSM** | Reliable control link |

📄 **For a complete list of parts, cables, and tools, please check the [BOM List](./BOM.xlsx).**

## 🗺️ Roadmap & Versions

### ✅ v1.0.0: The Visual Baseline
**Focus:** Establishing a stable flight platform using Visual-Inertial Odometry (VIO).
* **Localization:** [VINS-Fusion](https://github.com/HKUST-Aerial-Robotics/VINS-Fusion) (Stereo + IMU)
* **Planning:** [EGO-Planner](https://github.com/ZJU-FAST-Lab/ego-planner)
* **Key Hardware:** Jetson NX + D435

### ✅ v1.1.0: Lidar-Inertial Upgrade (Completed)
**Focus:** Integrating Livox Mid-360 for robust, high-precision localization in complex environments.
* **Localization:** [FAST-LIO2](https://github.com/hku-mars/FAST_LIO) / [DLIO](https://github.com/vectr-ucla/direct_lidar_inertial_odometry) (LiDAR-Inertial Odometry) with Livox Mid-360
* **Planning:** [EGO-Planner](https://github.com/ZJU-FAST-Lab/ego-planner) for waypoint (fixed-point) navigation
* **Key Hardware:** Jetson NX + Mid-360 + D435
* **Result:** Stable indoor localization (hover) and autonomous waypoint navigation verified on the real platform.
* 🎬 **Demo Videos:**
  * [FASTLIO2.mp4](./FASTLIO2.mp4) — Stable hover with FAST-LIO2 localization
  * [DLIO+egoplanner.mp4](./DLIO+egoplanner.mp4) — Autonomous waypoint navigation with DLIO + EGO-Planner

### 🚀 v1.2.0: Autonomous Exploration & Agility (Next Target)
**Focus:** From waypoint navigation to fully autonomous exploration with a lighter, faster platform.
* **Autonomous Exploration:** Frontier/sampling-based exploration in unknown environments.
* **Higher Flight Speed:** Push planning and control toward more aggressive, faster flight.
* **Mechanical Optimization:** Redesign mounts and structure to reduce airframe weight.

### 🔮 Future Goals: Intelligent Control
**Focus:** Advanced research driven by Deep Reinforcement Learning.
* End-to-end Navigation using DRL.
* Sim-to-Real transfer for complex maneuvers.
* Integration of Neural Network-based perception modules.

## 📂 Repository Structure
```text
.
├── BOM.xlsx                    # Detailed Hardware Bill of Materials
├── FASTLIO2.mp4                # v1.1.0 demo: stable hover with FAST-LIO2 localization
├── DLIO+egoplanner.mp4         # v1.1.0 demo: DLIO + EGO-Planner waypoint navigation
└── README.md                   # This file
