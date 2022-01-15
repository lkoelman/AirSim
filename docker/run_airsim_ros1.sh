#!/bin/bash

# Set X-server access privileges
xhost +local:root

# Start up containers in background (-d)
docker-compose -f compose-ros1.yml up -d

# NOTE: can only build ROS nodes after AirSim code is mounted in shared volume

## Configure ROS container
# enter container:
docker exec -t docker_ros_1 bash
# in container:

# NOTE: the AirSim source volume is persisted across runs, so no need to rebuild after first run
source /opt/ros/melodic/setup.bash
cd ~/AirSim/ros
catkin clean
catkin build -DCMAKE_C_COMPILER=gcc-8 -DCMAKE_CXX_COMPILER=g++-8

## Start nodes
source devel/setup.bash;
roslaunch airsim_ros_pkgs airsim_node.launch;
roslaunch airsim_ros_pkgs rviz.launch;

## MAVROS: launch mavlink node
roslaunch mavros px4.launch fcu_url:="udp://:14557@"

## Run PX4 container
### A: in Docker, with rebuild
# => just uncomment PX4 container in compose-ros1.yml
### B: in Docker, with PX4 sources on host to prevent rebuild
# docker run -it --rm --privileged --env=LOCAL_USER_ID="$(id -u)" -v ~/workspace/PX4/PX4-Autopilot:/src/PX4-Autopilot/:rw -v /tmp/.X11-unix:/tmp/.X11-unix:ro -e DISPLAY=:0 -p 14570:14570/udp --net=host px4io/px4-dev-nuttx-focal:src-v1.12.3 make px4_sitl none_iris
### C: entirely on host
### => see https://microsoft.github.io/AirSim/px4_sitl/
PX4_SRC="$HOME/workspace/PX4-local/PX4-Autopilot"
bash ${PX4_SRC}/Tools/setup/ubuntu.sh --no-nuttx --no-sim-tools
cd $PX4_SRC
make px4_sitl none_iris

# Disable x-server privileges
xhost -local:root