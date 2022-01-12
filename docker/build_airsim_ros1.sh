#!/bin/bash
AIRSIM_ROOT=".."

# Build ROS container
docker build -t ros_airsim_deps:melodic-ros-base \
    -f $AIRSIM_ROOT/tools/Dockerfile-ROS $AIRSIM_ROOT/tools

xhost +local:root
docker-compose -f compose-ros1.yml up

xhost -local:root

# in container:
# source /opt/ros/melodic/setup.bash
# cd ~/AirSim/ros
# catkin build -DCMAKE_C_COMPILER=gcc-8 -DCMAKE_CXX_COMPILER=g++-8
# roslaunch airsim_ros_pkgs airsim_node.launch;
# roslaunch airsim_ros_pkgs rviz.launch;