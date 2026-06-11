#!/usr/bin/env bash
# [T4] relay /Odometry_highrate -> /Odometry (topic_tools is in /opt/ros).
source /opt/ros/noetic/setup.bash
echo "[T4] relay /Odometry_highrate -> /Odometry"
exec rosrun topic_tools relay /Odometry_highrate /Odometry
