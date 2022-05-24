#!/bin/sh

__ACTION=$1
__CMD=$@

PODCONDA_AWK_CMD="awk"

PODCONDA_PODMAN="podman"
PODCONDA_PODMAN_CMD=""
PODCONDA_PODMAN_ROOT=""
PODCONDA_PODMAN_GLOBAL=""

PODCONDA_IMAGE="docker.io/imbearchild/podconda:latest"
#PODCONDA_IMG_TYPE="podconda"
PODCONDA_CONTAINER="podconda"
PODCONDA_PUBLISH_PORT="8888"

function _read_var() {
    if [ -f ~/.config/podconda.sh.rc ]; then
        #_echo "loading podcondarc"
        . ~/.config/podconda.sh.rc
    fi
    if [ "$__PODCONDA_PODMAN" != '' ]; then
        PODCONDA_PODMAN_CMD=$__PODCONDA_PODMAN
    fi
    if [ "$__PODCONDA_PODMAN_ROOT" != '' ]; then
        PODCONDA_PODMAM_ROOT=$__PODCONDA_PODMAN_ROOT
    fi

    PODCONDA_PODMAN_CMD="$PODCONDA_PODMAN $PODCONDA_PODMAN_GLOBAL"

    if [ "$PODCONDA_PODMAN_ROOT" != '' ]; then
        PODCONDA_PODMAN_CMD="$PODCONDA_PODMAN_CMD --root $PODCONDA_PODMAN_ROOT"
    fi

}

function _echo() {
    local OPTIND __echo_opts __echo
    echo -e "[podconda.sh] \c"
    __echo="echo"
    while getopts e __echo_opts; do
        case $__echo_opts in
        e)
            shift $(($OPTIND - 1))
            __echo="echo -e"
            ;;
        *)
            shift $(($OPTIND - 1))
            
            ;;
        esac
    done
    $__echo $*
}

function _prompt_confirm() {
    local OPTIND __prompt_yn __answer
    while getopts yn __prompt_yn; do
        case $__prompt_yn in
        y)
            _echo -e "$2 [Y/n]: \c"
            read __answer
            if [ "$__answer" != "${__answer#[Yy]}" ]; then # this grammar (the #[] operator) means that the variable $answer where any Y or y in 1st position will be dropped if they exist.
                return 1
            elif [ "$__answer" = "" ]; then
                return 1
            else
                return 0
            fi
            ;;
        n)
            _echo -e "$2 [y/N]: \c"
            read __answer
            if [ "$__answer" != "${__answer#[Yy]}" ]; then 
                return 1
            elif [ "$__answer" = "" ]; then
                return 0
            else
                return 0
            fi
            ;;
        esac
    done

}

function _podconda_init() {
    _echo "creating podconda container"
    $PODCONDA_PODMAN_CMD container create --init --name $PODCONDA_CONTAINER --publish 8888:$PODCONDA_PUBLISH_PORT $PODCONDA_IMAGE
}

function _podconda_check() {
    if [ "$1" = 'exist' ]; then
        $PODCONDA_PODMAN_CMD container exists $PODCONDA_CONTAINER
        if [ $? -ne 0 ]; then
            if [ $2 = 'echo-exit' ]; then
                _echo "error: No container exists! Use \"podconda.sh init\" to creat one."
                exit
            fi
            return 0 # not exist
        else
            return 1 # exist
        fi
    elif [ "$1" = 'running' ]; then
        _RUNNING=$($PODCONDA_PODMAN_CMD container ps --format "{{.Names}}" --filter "name=$PODCONDA_CONTAINER" --filter "status=running")
        if [ "$_RUNNING" = "$PODCONDA_CONTAINER" ]; then
            return 1 # running
        else
            if [ "$2" = 'echo-exit' ]; then
                _echo "error: Container is not running! Use \"podconda.sh start\" to start it."
                exit
            fi
            return 0 # running
        fi
    else
        _echo "internal error: no command given at _podconda_check"
    fi
}

function _podconda_start() {
    _echo "starting container"
    $PODCONDA_PODMAN_CMD container start $PODCONDA_CONTAINER
    sleep 4
    _echo "acquiring token"
    $PODCONDA_PODMAN_CMD exec --interactive $PODCONDA_CONTAINER bash -c "/opt/conda/bin/jupyter server list"
    if [ $? -ne 0 ]; then
        _echo "error: Failed to acquire token of jupyter server!"
        $PODCONDA_PODMAN_CMD container start --attach $PODCONDA_CONTAINER
        exit
    fi
}

function _podconda_stop() {
    _podconda_check running echo-exit
    _echo "stopping container"
    #$PODCONDA_PODMAN_CMD exec --interactive $PODCONDA_CONTAINER bash -c "podconda_jupyterlab_stop.sh"
    _podconda_check running
    if [ $? -eq 1 ]; then
        _echo "error: Failed to gently stop jupyter server! Killing..."
        $PODCONDA_PODMAN_CMD container stop -t5 $PODCONDA_CONTAINER
    fi
}

function _podconda_clean() {
    _echo "clean"
    _prompt_confirm -n "Are you sure? "
    if [ $? -eq 1 ]; then
        $PODCONDA_PODMAN_CMD container rm $PODCONDA_CONTAINER
    fi
}

function _podconda_shell() {
    $PODCONDA_PODMAN_CMD exec --tty --interactive $PODCONDA_CONTAINER /usr/bin/bash -l
}

function _podconda_dev() {
    _echo -e "development tool here!"
    __ACTION=$1
    if [ "$__ACTION" = 'build' ]; then
        $PODCONDA_PODMAN_CMD build --layers=true --tag $PODCONDA_CONTAINER ./
        exit
    elif [ "$__ACTION" = 'push' ]; then
        $PODCONDA_PODMAN_CMD push $PODCONDA_IMAGE
        exit
    elif [ "$__ACTION" = 'podman' ]; then
        $PODCONDA_PODMAN_CMD $(echo $@ | $PODCONDA_AWK_CMD '{$1=""; print $0}')
        exit
    else
        _echo "no command given"
    fi
}

_read_var
if [ "$__ACTION" = 'init' ]; then
    _podconda_init
    exit
elif [ "$__ACTION" = 'start' ]; then
    _podconda_check exist echo-exit
    _podconda_start
    exit
elif [ "$__ACTION" = 'stop' ]; then
    _podconda_check exist echo-exit
    _podconda_stop
    exit
elif [ "$__ACTION" = 'clean' ]; then
    _podconda_check exist echo-exit
    _podconda_clean $(echo $__CMD | $PODCONDA_AWK_CMD '{$1=""; print $0}')
    exit
elif [ "$__ACTION" = 'shell' ]; then
    _podconda_check exist echo-exit
    _podconda_check running echo-exit
    _podconda_shell
    exit
elif [ "$__ACTION" = 'dev' ]; then
    _podconda_dev $(echo $__CMD | $PODCONDA_AWK_CMD '{$1=""; print $0}')
    exit
else
    if [ "$__ACTION" = '' ]; then
        _echo "no command provided"
    else
        _echo "no command action:" $__ACTION
    fi
    _echo "usage: podconda.sh <command> [<args>]"
    _echo "available command: "
    _echo -e "\c" && printf "    init    create and initialize a podconda container \n"
    _echo -e "\c" && printf "    start   start the podconda container \n"
    _echo -e "\c" && printf "    shell   run a interactive bash shell inside the container \n"
    _echo -e "\c" && printf "    stop    stop the podconda container \n"
    _echo -e "\c" && printf "    clean   remove the container with all data in it \n"
    exit
fi
