#!/usr/bin/env bash
set -e
# DLIO + EGO-Planner + PX4 (DLIO replaces FAST-LIO). Does NOT arm/takeoff.
# Each component runs in its own subshell with ONLY the workspace it needs,
# to avoid multi-workspace overlay clobbering (sourcing dlio_ws drops livox_ws).

pids=()
cleanup(){ for p in "${pids[@]}"; do kill "$p" 2>/dev/null || true; done; }
trap cleanup EXIT INT TERM

sudo chmod 777 /dev/ttyACM0 || true

# T2 Livox (PointCloud2)
( source /opt/ros/noetic/setup.bash; source "$HOME/livox_ws/devel/setup.bash"
  roslaunch livox_ros_driver2 msg_MID360.launch xfer_format:=0 ) &
pids+=("$!"); sleep 3

# T3 DLIO
( source /opt/ros/noetic/setup.bash; source "$HOME/dlio_ws/devel/setup.bash"
  roslaunch direct_lidar_inertial_odometry dlio_mid360_drone.launch rviz:=false ) &
pids+=("$!"); sleep 4

# T4 relay -> /Odometry
( source /opt/ros/noetic/setup.bash
  rosrun topic_tools relay /Odometry_highrate /Odometry ) &
pids+=("$!"); sleep 1

# T5 MAVROS
( source /opt/ros/noetic/setup.bash
  roslaunch mavros px4.launch ) &
pids+=("$!"); sleep 8

# T6 px4ctrl
( source /opt/ros/noetic/setup.bash; source "$HOME/Fast-Drone-250/devel/setup.bash"
  roslaunch px4ctrl run_ctrl.launch odom_topic:=/Odometry_highrate ) &
pids+=("$!"); sleep 2

# T7 ego-planner (foreground)
source /opt/ros/noetic/setup.bash; source "$HOME/Fast-Drone-250/devel/setup.bash"
roslaunch ego_planner single_run_in_exp.launch
