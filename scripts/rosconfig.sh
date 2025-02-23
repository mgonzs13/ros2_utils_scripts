# Copyright (C) 2023  Miguel Ángel González Santamarta

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.

# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.

# autocomplete
function _auto_complete_rosconfig() {

   # ros distros
   local ros_distros=$(ls /opt/ros/)
   local ros_distros_str=""
   for distro in $ros_distros; do
      ros_distros_str="${ros_distros_str} ${distro}"
   done

   # complete
   compopt +o default

   case $3 in
   -d) COMPREPLY+=($(compgen -W "${ros_distros_str}" "${COMP_WORDS[$COMP_CWORD]}")) ;;
   -w)
      compopt -o default
      COMPREPLY+=()
      ;;
   -m) COMPREPLY+=() ;;
   -i) COMPREPLY+=() ;;
   -h) COMPREPLY+=() ;;
   *) COMPREPLY+=($(compgen -W "-d -w -m -i -h" -- "${COMP_WORDS[$COMP_CWORD]}")) ;;
   esac
}
complete -F _auto_complete_rosconfig rosconfig

# command
function rosconfig() {

   ROS_DISTRO=foxy
   ROS_WS=~/ros2_ws
   local PATH_TO_INSTALL_DIR=""

   ROS_MASTER_URI=127.0.0.1
   ROS_IP=127.0.0.1

   helpFunction() {
      echo ""
      echo "Usage: rosconfig -d ROS_DISTRO -w ROS_WS -m ROS_MASTER_URI -i ROS_IP"
      echo -e "\t-d ROS_DISTRO"
      echo -e "\t-w ROS_WS"
      echo -e "\t-m ROS_MASTER_URI"
      echo -e "\t-i ROS_IP"
      echo -e "\t-h Help"
   }

   local OPTIND
   while getopts "d:w:m:i:h" opt; do
      case "$opt" in
      h)
         helpFunction
         return
         ;;
      d) ROS_DISTRO="$OPTARG" ;;
      w) ROS_WS="${OPTARG%/}" ;;
      m) ROS_MASTER_URI="$OPTARG" ;;
      i) ROS_IP="$OPTARG" ;;
      ?)
         helpFunction
         return
         ;;
      esac
   done

   if [ ! -d "/opt/ros/$ROS_DISTRO" ]; then
      echo "ROS distro $ROS_DISTRO is not installed"
      return
   fi

   source /opt/ros/$ROS_DISTRO/setup.bash

   local gazebo_setup=/usr/share/gazebo/setup.bash
   if [ -f "$gazebo_setup" ]; then
      source /usr/share/gazebo/setup.bash
   fi

   case "$ROS_VERSION" in
   1)
      echo "ROS1 $ROS_DISTRO"
      export ROS_MASTER_URI=http://$ROS_MASTER_URI:11311/
      export ROS_IP=$ROS_IP
      PATH_TO_INSTALL_DIR=$ROS_WS/devel
      ;;

   2)
      echo "ROS2 $ROS_DISTRO"
      _colcon_cd_root=/opt/ros/$ROS_DISTRO/
      PATH_TO_INSTALL_DIR=$ROS_WS/install
      ;;

   *) echo "Wrong ROS version. Versions are: 1 and 2" ;;
   esac

   if [ -d "$ROS_WS" ]; then
      if [ -f "$PATH_TO_INSTALL_DIR/setup.bash" ]; then
         source $PATH_TO_INSTALL_DIR/setup.bash
      fi
   fi

}
