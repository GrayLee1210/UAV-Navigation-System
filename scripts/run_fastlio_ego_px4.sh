#!/usr/bin/env bash
set -e

# FAST-LIO2 + EGO-Planner + PX4 control startup.
# This script does not arm or take off. Use takeoff.sh only after all topics are healthy.

source /opt/ros/noetic/setup.bash
source "$HOME/livox_ws/devel/setup.bash"
source "$HOME/fast_lio2_ws/devel/setup.bash"
source "$HOME/Fast-Drone-250/devel/setup.bash"

pids=()
cleanup() {
  for pid in "${pids[@]}"; do
    kill "$pid" 2>/dev/null || true
  done
}
trap cleanup EXIT INT TERM

sudo chmod 777 /dev/ttyACM0 || true

roslaunch livox_ros_driver2 msg_MID360.launch &
pids+=("$!")
sleep 3

roslaunch fast_lio mapping_mid360.launch rviz:=false &
pids+=("$!")
sleep 3

roslaunch mavros px4.launch &
pids+=("$!")
sleep 8

roslaunch px4ctrl run_ctrl.launch odom_topic:=/Odometry_highrate &
pids+=("$!")
sleep 2

roslaunch ego_planner single_run_in_exp.launch
