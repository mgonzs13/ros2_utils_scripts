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
        COMPREPLY+=($(compgen -W "-j -WHITE_LIST -BLACK_LIST -SYMLINK -SEQUENCIAL -h" -- "$cur"))
        ;;
    esac
}
complete -F _auto_complete_colcon_make colcon_make

function colcon_make() {

    local JOBS=$(grep -c ^processor /proc/cpuinfo)
    local WHITE_LIST=()
    local BLACK_LIST=()
    local SYMLINK=""
    local SEQUENCIAL=""

    helpFunction() {
        echo ""
        echo "Usage: colcon_make -j JOBS -WHITE_LIST WHITE_LIST -BLACK_LIST BLACK_LIST -SYMLINK -SEQUENCIAL"
        echo -e "\t-j JOBS"
        echo -e "\t-WHITE_LIST \"WHITE_LIST\" (ROS 2 pacakges separated by :)"
        echo -e "\t-BLACK_LIST \"BLACK_LIST\" (ROS 2 pacakges separated by :)"
        echo -e "\t-SYMLINK"
        echo -e "\t-SEQUENCIAL"
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
        -SYMLINK) SYMLINK="--symlink-install" ;;
        -SEQUENCIAL) SEQUENCIAL="--executor sequential" ;;

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

    local colcon_cmd="export MAKEFLAGS='-j ${JOBS}' && colcon build ${SYMLINK} --parallel-workers ${JOBS} ${SEQUENCIAL} $WHITE_LIST $BLACK_LIST && source install/setup.bash"
    eval $colcon_cmd
    unset MAKEFLAGS
}
