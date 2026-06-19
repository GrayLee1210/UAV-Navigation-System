# vio — VINS-Fusion (visual-inertial odometry)

[VINS-Fusion](https://github.com/HKUST-Aerial-Robotics/VINS-Fusion) kept here as an
**optional** visual-inertial front-end. The drone currently flies on LiDAR-inertial
odometry (FAST-LIO2 / DLIO under `../localization/`); VINS is retained for future
vision-based work and is **not** required by the EGO-Planner / FUEL flight stack.

## What was changed vs. upstream

`loop_fusion` failed to link on this Jetson (Ubuntu 20.04, aarch64) with
`undefined reference to cv::Mat::Mat()`. Root cause: the source is compiled against
the **OpenCV 4.2** headers (source build in `/usr/local`) but a prior hard-coded hack
linked the **apt OpenCV 4.5** libs in `/usr/lib/aarch64-linux-gnu` — an ABI mismatch.

Fix (`loop_fusion/CMakeLists.txt`, see `../../patches/vins_loop_fusion_opencv4.2_fix.patch`):
1. Repoint the hard-coded libs `/usr/lib/aarch64-linux-gnu/libopencv_*.so` → `/usr/local/lib/libopencv_*.so` (4.2).
2. Put `${OpenCV_INCLUDE_DIRS}` (4.2) **before** `${catkin_INCLUDE_DIRS}` in `include_directories`,
   so the 4.2 headers win over the 4.5 headers that `cv_bridge` injects.

Build (no `-DOpenCV_DIR` needed — `find_package(OpenCV 4)` already resolves 4.2 in `/usr/local`):

```bash
cd ~/Drone/vio/vins_ws && catkin_make -DCMAKE_BUILD_TYPE=Release -j4 -l4
```

## Files not vendored (fetch from upstream)

To keep the repo lean these large upstream assets are excluded — restore from the
[upstream repo](https://github.com/HKUST-Aerial-Robotics/VINS-Fusion):

- `support_files/brief_k10L6.bin` (≈58 MB DBoW vocabulary, **required at runtime** by loop_fusion)
- `global_fusion/models/*.dae`, `*.mesh` (visualization meshes)
- `support_files/image/*`, `support_files/paper/*` (docs/media)

A source-built `cv_bridge` (OpenCV 4.2, from `vision_opencv`) must also be present in the
workspace so the whole stack stays on OpenCV 4.2.
