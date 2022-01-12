#!/bin/bash

docker build -f Dockerfile-ROS2 -t ros_airsim_deps:galactic-ros-base .

xhost +local:root
docker-compose -f compose-ros2.yml up
xhost -local:root