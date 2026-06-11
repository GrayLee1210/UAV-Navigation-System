#!/usr/bin/env bash

rosbag record --tcpnodelay \
/livox/lidar \
/livox/imu \
/Odometry \
/Odometry_highrate \
/cloud_registered \
/cloud_registered_body \
/path \
/drone_0_ego_planner_node/grid_map/occupancy \
/drone_0_ego_planner_node/grid_map/occupancy_inflate \
/drone_0_ego_planner_node/goal_point \
/drone_0_ego_planner_node/optimal_list \
/drone_0_ego_planner_node/a_star_list \
/drone_0_planning/bspline \
/position_cmd \
/debugPx4ctrl \
/mavros/state \
/mavros/imu/data \
/mavros/setpoint_raw/attitude \
/mavros/local_position/odom \
/move_base_simple/goal \
/tf \
/tf_static
