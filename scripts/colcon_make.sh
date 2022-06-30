
alias colcon_make="unset MAKEFLAGS && colcon build --symlink-install && source install/setup.bash"

alias colcon_make_light="export MAKEFLAGS='-j 1' && colcon build --symlink-install --parallel-workers 1 --executor sequential && source install/setup.bash"
