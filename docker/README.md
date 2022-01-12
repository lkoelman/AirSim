
# UE4 Docker container from source

We want to be able to build AirSim + its ROS wrapper inside the container.
Hence, we have to follow the approach described on https://microsoft.github.io/AirSim/docker_ubuntu/#source

In short, the steps will be:
- build Docker container with UE4 engine build tools (using ue4-docker tool)
- install ROS in the container
- build AirSim with ROS support following https://microsoft.github.io/AirSim/airsim_ros_pkgs/

First link your Epic Games and GitHub accounts [here](https://www.epicgames.com/account/connections#accounts),
go to GitHub and accept the invitation to the GitHub organization.

Create a personal access token on https://github.com/settings/tokens
and set the scope to include repository read access.

```sh
# Install ue4-docker following the instructions at
# https://docs.adamrehn.com/ue4-docker/configuration/configuring-linux#step-3-install-ue4-docker
python3 -m pip install ue4-docker

# Here you will need to enter your GitHub username and personal access tokenas password
ue4-docker build 4.27.2 --cuda=10.2 --no-full

# Find built container and note down its name
docker images
UE4_IMG="adamrehn/ue4-engine:4.27.2-cudagl10.2"
```

Build the AirSim container with

```sh
cd Airsim/docker
python build_airsim_image.py \
   --source \
   --base_image $UE4_IMG \
   --target_image=airsim_source:4.19.2-cudagl10.2
```

Either modify the template file `Airsim/docker/Docker_source` or
do the installation manually afterward.


# Pre-built UE4 images

We want to be able to build AirSim + its ROS wrapper inside the container.
Instead of building the UE4 Docker image from scratch, we can use the
images provided by Epic Games (new since Unreal version 4.27).

https://unrealcontainers.com/docs/obtaining-images/image-sources#sources-of-unreal-engine-development-images
https://docs.unrealengine.com/4.27/en-US/SharingAndReleasing/Containers/ContainersOverview/
https://docs.unrealengine.com/4.27/en-US/SharingAndReleasing/Containers/ContainersQuickStart/
https://github.com/orgs/EpicGames/packages/container/package/unreal-engine

First link your Epic Games and GitHub accounts and accept the
invitation to the Unreal Engine GitHub organization.

Get the official Unreal engine container:

```sh
GH_USER="Your GitHub username"
TOKEN="<github personal access token>"
echo $TOKEN | docker login ghcr.io -u $GH_USER --password-stdin

UE4_IMG=ghcr.io/epicgames/unreal-engine:dev-slim-4.27.2
docker pull $UE4_IMG
```


Using the scripts in Airsim/docker:

```sh
# build the docker image
python3 build_airsim_image.py --ros2

# start container with GPU and X-server pass-through
./run_airsim_image_source.sh airsim_ros2:dev-slim-4.27.2

# inside container, start the UE4 editor
/home/ue4/UnrealEngine/Engine/Binaries/Linux/UE4Editor

# Run an unpackaged environment (.uproject) -> open it in editor
# Run a packaged environment -> run the .sh file of the environment
```

# Packaged binary environment

```sh
# in terminal 1, start AirSim
./AbandonedPark.sh -ResX=1280 -ResY=720 -WINDOWED

# in terminal 2, control AirSim using API

# install airsim python bindings (below must be separate commands)
python3 -m pip install numpy
python3 -m pip install msgpack-rpc-python
python3 -m pip install airsim

# Execute python example from: PythonClient/multirotor/hello_drone.py
ipython
>>> import airsim
>>> import os
>>> 
>>> # connect to the AirSim simulator
>>> client = airsim.MultirotorClient()
>>> client.confirmConnection()
>>> client.enableApiControl(True)
>>> client.armDisarm(True)

>>> # Async methods returns Future. Call join() to wait for task to complete.
>>> client.takeoffAsync().join()
>>> client.moveToPositionAsync(-10, 10, -10, 5).join()

```

# ROS

AirSim Python and C++ API are entirely separate from the Plugin Code.
You can even run an AirSim packaged binary, and use the C++ or Python
API to communicate with it, as long as you're on the same API version.
This makes the setup very flexible: you can run the AirSim environment
and client in entirely different hosts/containers as long as they share a network, e.g.
- run AirSim binary on your main OS, run client in a (ROS) container
- run AirSim from editor in a container, run client in another (ROS) container

```sh
rosdep install --from-paths src --ignore-src -r -y
```


