#!/bin/bash
AIRSIM_ROOT=".."

# Build ROS container
## A: from official ROS-noetic-desktop image
docker build -t ros_airsim_deps:noetic-ros-full -f Dockerfile-ROS-desktop .
## B: from modied AirSim ROS image
# docker build -t ros_airsim_deps:melodic-ros-full \
#     -f $AIRSIM_ROOT/tools/Dockerfile-ROS $AIRSIM_ROOT/tools

# Build PX4 container
PX4_IMG=px4io/px4-dev-nuttx-focal
PX4_STABLE="v1.12.3"
docker build -f Dockerfile-PX4 \
    --build-arg BASE_IMAGE=${PX4_IMG} \
    --build-arg PX4_STABLE=${PX4_STABLE} \
    -t ${PX4_IMG}:src-${PX4_STABLE} .
