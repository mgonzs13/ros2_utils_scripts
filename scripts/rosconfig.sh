
# autocomplete
function _auto_complete_rosconfig(){

   # ros distros
   ros_distros=`ls /opt/ros/`
   ros_distros_str=""
   for distro in $ros_distros
   do
      ros_distros_str="${ros_distros_str} ${distro}"
   done

   # complete
   compopt +o default

   case $3 in
      -d) COMPREPLY+=($(compgen -W "${ros_distros_str}" "${COMP_WORDS[$COMP_CWORD]}"));;
      -w) compopt -o default 
          COMPREPLY+=();;
      -m) COMPREPLY+=();;
      -i) COMPREPLY+=();;
      -h) COMPREPLY+=();;
      *) COMPREPLY+=($(compgen -W "-d -w -m -i -h" -- "${COMP_WORDS[$COMP_CWORD]}"));;
   esac
}
complete -F _auto_complete_rosconfig rosconfig


# command
function rosconfig(){

   ROS_DISTRO=foxy
   PATH_TO_ROS_WS=~/ros2_ws   

   ROS_MASTER_URI=127.0.0.1
   ROS_IP=127.0.0.1

   helpFunction(){
      echo ""
      echo "Usage: rosconfig -d ROS_DISTRO -w PATH_TO_ROS_WS -m ROS_MASTER_URI -i ROS_IP"
      echo -e "\t-d ROS_DISTRO"
      echo -e "\t-w PATH_TO_ROS_WS"
      echo -e "\t-m ROS_MASTER_URI"
      echo -e "\t-i ROS_IP"
      echo -e "\t-h Help"
   }

   local OPTIND
   while getopts "d:w:m:i:h" opt
   do
      case "$opt" in
         h ) helpFunction
             return ;;
         d ) ROS_DISTRO="$OPTARG" ;;
         w ) PATH_TO_ROS_WS="${OPTARG%/}" ;;
         m ) ROS_MASTER_URI="$OPTARG" ;;
         i ) ROS_IP="$OPTARG" ;;
         ? ) helpFunction
             return;;
      esac
   done

   if [ ! -d "/opt/ros/$ROS_DISTRO" ]; then 
      echo "ROS distro $ROS_DISTRO is not installed"
      return
   fi

   source /opt/ros/$ROS_DISTRO/setup.bash

   case "$ROS_VERSION" in 
      1) echo "ROS1 $ROS_DISTRO"
         export ROS_MASTER_URI=http://$ROS_MASTER_URI:11311
         export ROS_IP=$ROS_IP
         PATH_TO_ROS_WS=$PATH_TO_ROS_WS/devel
         ;;

      2) echo "ROS2 $ROS_DISTRO"
         PATH_TO_ROS_WS=$PATH_TO_ROS_WS/install
         ;;

      *) echo "Wrong ROS version. Versions are: 1 and 2" ;; 
   esac

   if [ -d "$PATH_TO_ROS_WS" ]; then 
      source $PATH_TO_ROS_WS/setup.bash
   fi

}
