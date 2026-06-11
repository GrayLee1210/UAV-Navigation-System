<div align="right">

**English** | [简体中文](README.zh-CN.md)

</div>

# UAV Autonomous Navigation Platform (250mm)

> **Current Status:** ✅ v1.1.0 Completed — LiDAR-Inertial Localization & Waypoint Navigation Verified
> **Latest Version:** v1.1.0

## 📖 Introduction

This repository documents the iterative development of a custom **250mm wheelbase quadrotor** designed for advanced autonomous navigation and control research.

The goal is to build a robust hardware and software foundation, starting from classical SLAM and planning algorithms, and gradually migrating towards **Deep Reinforcement Learning (DRL)** based perception and control systems.

## 🎬 Demo (v1.1.0)

| FAST-LIO2 Localization — Stable Hover | DLIO + EGO-Planner — Autonomous Waypoint Navigation (4× speed) |
| :---: | :---: |
| ![FAST-LIO2 stable hover](docs/assets/fastlio2_hover.gif) | ![DLIO + EGO-Planner navigation](docs/assets/dlio_ego_nav.gif) |
| [Full video](videos/FASTLIO2.mp4) | [Full video](videos/DLIO+egoplanner.mp4) |

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

## 🧩 Software Architecture (v1.1.0)

```mermaid
graph LR
    A[Livox Mid-360] -->|/livox/lidar, /livox/imu| B[livox_ros_driver2]
    B --> C["FAST-LIO2 / DLIO<br>(LiDAR-Inertial Odometry)"]
    C -->|"/Odometry_highrate (~IMU rate)"| D[px4ctrl]
    C -->|/Odometry + /cloud_registered| E[EGO-Planner]
    E -->|position commands| D
    D --> F[MAVROS] --> G[PX4 / Pixhawk 4]
```

Two interchangeable localization front-ends drive the same planning and control stack:

- **FAST-LIO2 pipeline** — `scripts/run_fastlio_ego_px4.sh`
- **DLIO pipeline** — `scripts/run_dlio_ego_px4.sh` (DLIO as a drop-in replacement for FAST-LIO2)

### Key Modifications vs. Upstream

| Module | Upstream (pinned commit) | What was changed here |
| :--- | :--- | :--- |
| **FAST-LIO2** (`src/FAST_LIO`) | [hku-mars/FAST_LIO](https://github.com/hku-mars/FAST_LIO) `7cc4175` | ① **High-rate odometry**: new `PropagateHighRateState()` forward-propagates the latest LIO state with each incoming IMU sample and publishes `/Odometry_highrate` (~IMU rate) for `px4ctrl`, instead of the ~10 Hz LiDAR-rate `/Odometry`. ② Ported from `livox_ros_driver` to `livox_ros_driver2`. ③ Mid-360 config tuning (`config/mid360.yaml`). |
| **DLIO** (`src/direct_lidar_inertial_odometry`) | [vectr-ucla/direct_lidar_inertial_odometry](https://github.com/vectr-ucla/direct_lidar_inertial_odometry) `fc8d183` | ① New `imu/accelScale` parameter — the Mid-360 IMU reports acceleration in **g**, not m/s², so it is rescaled by 9.80665. ② Mid-360 extrinsics in `cfg/dlio.yaml` (aligned with FAST-LIO2's `mid360.yaml`). ③ New `launch/dlio_mid360_drone.launch` remaps DLIO outputs to `/Odometry_highrate` + `/cloud_registered`, making DLIO a drop-in replacement for FAST-LIO2 in the same stack. |
| **EGO-Planner** (`ego_planner/`, from [Fast-Drone-250](https://github.com/ZJU-FAST-Lab/Fast-Drone-250) `8ff6427`) | launch/config only | ① Odometry source switched from VINS-Fusion (`/vins_fusion/imu_propagate`) to LIO (`/Odometry`). ② `grid_map` is built directly from the LiDAR registered cloud (`cloud_registered`) instead of the depth camera. ③ `max_acc` lowered 6.0 → 2.0 for safe indoor flight. Full diff in `patches/`. |
| **livox_ros_driver2** | [Livox-SDK/livox_ros_driver2](https://github.com/Livox-SDK/livox_ros_driver2) `6b9356c` | **Not vendored** — use upstream directly. Only the network config differs: see `config/livox/MID360_config.json` (host `192.168.1.50`, LiDAR `192.168.1.154`). |

> `patches/` contains the exact diffs of every module against its pinned upstream commit, for review and re-application.

## 📂 Repository Structure

```text
.
├── README.md / README.zh-CN.md   # This file (EN) / Chinese version
├── BOM.xlsx                      # Detailed hardware Bill of Materials
├── docs/assets/                  # Demo GIFs embedded above
├── videos/                       # Full-length demo videos (mp4)
├── src/
│   ├── FAST_LIO/                 # Modified FAST-LIO2 (high-rate odom, driver2 port)
│   └── direct_lidar_inertial_odometry/   # Modified DLIO (accelScale, Mid-360 launch)
├── ego_planner/                  # Modified EGO-Planner launch + px4ctrl config
├── config/livox/                 # Mid-360 network config for livox_ros_driver2
├── patches/                      # Diffs vs. pinned upstream commits
└── scripts/                      # One-shot startup / takeoff / record scripts
```

## 🚀 Quick Start (on the drone, ROS Noetic)

```bash
# 1. Build the Livox driver (upstream) with the config from this repo
#    livox_ws/src/livox_ros_driver2  @ 6b9356c, replace config/MID360_config.json

# 2. Build the localization workspaces from this repo's sources
#    fast_lio2_ws/src/FAST_LIO                <- src/FAST_LIO
#    dlio_ws/src/direct_lidar_inertial_odometry <- src/direct_lidar_inertial_odometry

# 3. Build Fast-Drone-250 (upstream @ 8ff6427) and apply patches/fast_drone_250_*.patch

# 4. Launch the full stack (driver + LIO + relay + MAVROS + px4ctrl + EGO-Planner)
./scripts/run_fastlio_ego_px4.sh    # FAST-LIO2 pipeline
./scripts/run_dlio_ego_px4.sh       # or: DLIO pipeline

# 5. After all topics are healthy, take off
./scripts/takeoff.sh
```

## 🗺️ Roadmap & Versions

### ✅ v1.0.0: The Visual Baseline
**Focus:** Establishing a stable flight platform using Visual-Inertial Odometry (VIO).
* **Localization:** [VINS-Fusion](https://github.com/HKUST-Aerial-Robotics/VINS-Fusion) (Stereo + IMU)
* **Planning:** [EGO-Planner](https://github.com/ZJU-FAST-Lab/ego-planner)
* **Key Hardware:** Jetson NX + D435

### ✅ v1.1.0: LiDAR-Inertial Upgrade (Completed)
**Focus:** Integrating Livox Mid-360 for robust, high-precision localization in complex environments.
* **Localization:** [FAST-LIO2](https://github.com/hku-mars/FAST_LIO) / [DLIO](https://github.com/vectr-ucla/direct_lidar_inertial_odometry) (LiDAR-Inertial Odometry) with Livox Mid-360
* **Planning:** [EGO-Planner](https://github.com/ZJU-FAST-Lab/ego-planner) for waypoint (fixed-point) navigation
* **Key Hardware:** Jetson NX + Mid-360 + D435
* **Result:** Stable indoor localization (hover) and autonomous waypoint navigation verified on the real platform — see the demo GIFs above.

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

## 🙏 Acknowledgements

This project builds on the excellent open-source work of
[hku-mars/FAST_LIO](https://github.com/hku-mars/FAST_LIO),
[vectr-ucla/direct_lidar_inertial_odometry](https://github.com/vectr-ucla/direct_lidar_inertial_odometry),
[ZJU-FAST-Lab/Fast-Drone-250](https://github.com/ZJU-FAST-Lab/Fast-Drone-250) (EGO-Planner),
and [Livox-SDK/livox_ros_driver2](https://github.com/Livox-SDK/livox_ros_driver2).
