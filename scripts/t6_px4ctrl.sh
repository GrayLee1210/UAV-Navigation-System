#!/usr/bin/env bash
# [T6] px4ctrl. Source ros + Fast-Drone-250.
source /opt/ros/noetic/setup.bash
source "$HOME/Fast-Drone-250/devel/setup.bash"
echo "[T6] px4ctrl (odom=/Odometry_highrate)..."
exec roslaunch px4ctrl run_ctrl.launch odom_topic:=/Odometry_highrate
