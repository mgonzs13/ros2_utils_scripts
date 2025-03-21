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
function _auto_complete_colcon_make() {

    local cur prev words cword
    _init_completion -n : || return

    case $prev in

    -WHITE_LIST | -BLACK_LIST)
        COMPREPLY+=($(compgen -W "\[" "$cur"))

        # list ros2 pkgs
        local ros_pkgs=$(colcon list --base-paths $ROS_WS | awk '{print $1}')
        local ros_pkgs_str=""
        for pkg in $ros_pkgs; do
            ros_pkgs_str="${ros_pkgs_str} ${pkg}"
        done

        # complete
        if [[ "$cur" == *:* ]]; then
            local realcur prefix chosen remaining

            realcur="${cur##*:}"
            prefix="${cur%:*}"
            chosen=()
            IFS=$':\n' read -ra chosen <<<"$prefix"
            remaining=()
            readarray -t remaining <<<"$(printf '%s\n' "${ros_pkgs_str[@]}" "${chosen[@]}" | sort | uniq -u)"

            if [[ ${#remaining[@]} -gt 0 ]]; then
                COMPREPLY=($(compgen -W "${remaining[*]}" -- "$realcur"))

                if [[ ${#COMPREPLY[@]} -eq 1 && ${#remaining[@]} -gt 0 && "$realcur" == "${COMPREPLY[0]}" ]]; then
                    COMPREPLY=("${COMPREPLY[0]}:")
                fi
                if [[ ${#remaining[@]} -gt 1 ]]; then
                    compopt -o nospace
                fi
            fi
        else
            COMPREPLY=($(compgen -W "${ros_pkgs_str[*]}" -- "$cur"))

            if [[ ${#COMPREPLY[@]} -eq 1 && "$cur" == "${COMPREPLY[0]}" ]]; then
                COMPREPLY=("${COMPREPLY[0]}:")
            fi
            compopt -o nospace
        fi
        ;;

    -j) COMPREPLY+=() ;;

    *)
        COMPREPLY+=($(compgen -W "-j -WHITE_LIST -BLACK_LIST -NO-SYMLINK -SEQUENCIAL -h --cmake-args" -- "$cur"))
        ;;
    esac
}
complete -F _auto_complete_colcon_make colcon_make

function colcon_make() {

    local JOBS=$(grep -c ^processor /proc/cpuinfo)
    local WHITE_LIST=()
    local BLACK_LIST=()
    local SYMLINK="--symlink-install"
    local SEQUENCIAL=""
    local CMAKE_ARGS=""

    helpFunction() {
        echo ""
        echo "Usage: colcon_make -j JOBS -WHITE_LIST WHITE_LIST -BLACK_LIST BLACK_LIST -NO-SYMLINK -SEQUENCIAL --cmake-args CMAKE_ARGS"
        echo -e "\t-j JOBS"
        echo -e "\t-WHITE_LIST \"WHITE_LIST\" (ROS 2 pacakges separated by :)"
        echo -e "\t-BLACK_LIST \"BLACK_LIST\" (ROS 2 pacakges separated by :)"
        echo -e "\t-NO-SYMLINK"
        echo -e "\t-SEQUENCIAL"
        echo -e "\t--cmake-args \"CMAKE_ARGS\""
        echo -e "\t-h Help"
    }

    while [ $# -gt 0 ]; do
        case $1 in
        -h)
            helpFunction
            return
            ;;
        -j) JOBS="$2" ;;
        -WHITE_LIST) WHITE_LIST="$2" ;;
        -BLACK_LIST) BLACK_LIST="$2" ;;
        -NO-SYMLINK) SYMLINK="" ;;
        -SEQUENCIAL) SEQUENCIAL="--executor sequential" ;;
        --cmake-args) CMAKE_ARGS="--cmake-args $2" ;;
        esac
        shift
    done

    # white list
    if ((${#WHITE_LIST[@]})); then
        readarray -d ":" -t strarr <<<"$WHITE_LIST"
        WHITE_LIST="--packages-select"

        for ((n = 0; n < ${#strarr[*]}; n++)); do
            WHITE_LIST="${WHITE_LIST} ${strarr[n]}"
        done
    fi

    # black list
    if ((${#BLACK_LIST[@]})); then
        readarray -d ":" -t strarr <<<"${BLACK_LIST%]}"
        BLACK_LIST="--packages-skip"

        for ((n = 0; n < ${#strarr[*]}; n++)); do
            BLACK_LIST="${BLACK_LIST} ${strarr[n]}"
        done
    fi

    local colcon_cmd="export MAKEFLAGS='-j ${JOBS}' && colcon build ${SYMLINK} --parallel-workers ${JOBS} ${SEQUENCIAL} $WHITE_LIST $BLACK_LIST $CMAKE_ARGS && source install/setup.bash"
    eval $colcon_cmd
    unset MAKEFLAGS
}
