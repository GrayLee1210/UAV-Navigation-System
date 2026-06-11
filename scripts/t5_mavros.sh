#!/usr/bin/env bash
# [T5] MAVROS (mavros is in /opt/ros).
source /opt/ros/noetic/setup.bash
sudo chmod 777 /dev/ttyACM0 || true
echo "[T5] MAVROS (px4.launch)..."
exec roslaunch mavros px4.launch
