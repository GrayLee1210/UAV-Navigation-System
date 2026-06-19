#!/usr/bin/env bash
set -e
cd ~/FUEL
source /opt/ros/noetic/setup.bash
# Use the clean source-built OpenCV 4.2 in /usr/local for libs; plan_env
# CMakeLists forces its 4.2 headers ahead of cv_bridge auto-injected 4.5 headers.
catkin_make --source fuel_planner \
  -DCMAKE_BUILD_TYPE=Release \
  -DOpenCV_DIR=/usr/local/lib/cmake/opencv4 \
  -j4 -l4
