#!/usr/bin/env bash
# [T7] ego-planner. Source ros + Fast-Drone-250.
source /opt/ros/noetic/setup.bash
source "$HOME/Fast-Drone-250/devel/setup.bash"
echo "[T7] ego-planner..."
exec roslaunch ego_planner single_run_in_exp.launch
