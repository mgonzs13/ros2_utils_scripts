# ros2_utils_scripts

Set of shell scripts for ROS 2

## Installation

```shell
$ git clone https://github.com/mgonzs13/ros2_utils_scripts.git
$ echo "source ${PWD}/ros2_utils_scripts/scripts/all.sh" >> ~/.bashrc
```

## Scripts

### rosconfig

```shell
$ rosconfig -d ROS_DISTRO -w PATH_TO_ROS_WS -m ROS_MASTER_URI -i ROS_IP
```

```shell
$ rosconfig -d foxy -w ~/ros2_ws
```

```shell
$ rosconfig -d noetic -w ~/catkin_ws -m localhost -i localhost
```

### colcon_make

```shell
$ colcon_make -j JOBS -WHITE_LIST PKG1:PKG2 -BLACK_LIST PKG3:PKG4 -SYMLINK -SEQUENCIAL
```

```shell
$ colcon_make -j 1 -SEQUENCIAL
```
