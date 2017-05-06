#!/bin/bash

set -e

CMD=$1
REPO=repo
MACHINE=bbb
TARGET_IMAGE=console-image-obi

function usage {
    echo "Usage: $(basename $0)"
}

[ $# -eq 0 ] && usage && exit 1


if [ -z $DOCKER_WORK_DIR ]; then
    DOCKER_WORK_DIR=.
fi

[ -a $DOCKER_WORK_DIR ] || mkdir -p $DOCKER_WORK_DIR

pushd  $DOCKER_WORK_DIR

[ -a ./.netrc ] && cp ./.netrc ~

function do_repo_init {
    [ $# -eq 2 ] || (echo "wrong init command format";  usage;  exit 1)
    $REPO init -u $1 -b $2
}

function do_repo_sync {
    [ -a $DOCKER_WORK_DIR/.repo ] || (echo "repo was not init for workdir. Use 'init' first"; exit 1)
    $REPO sync
}

function do_build_init {
    [ -z $DOCKER_BUILD_DIR ] && DOCKER_BUILD_DIR=build
    OLD_DIR=`pwd`
    export BB_ENV_EXTRAWHITE="$BB_ENV_EXTRAWHITE LOCAL_BSPROOT"
    export LOCAL_BSPROOT=${DOCKER_WORK_DIR}
    . poky/oe-init-build-env ${DOCKER_BUILD_DIR}
    cp ${OLD_DIR}/pana/meta-pana/conf/bblayers.conf.sample.${MACHINE} ./conf/bblayers.conf
    cp ${OLD_DIR}/pana/meta-pana/conf/local.conf.sample.${MACHINE} ./conf/local.conf
}

function do_fetch {
    do_build_init
    bitbake -c fetchall ${TARGET_IMAGE}
}

function do_build {
    do_build_init
    bitbake ${TARGET_IMAGE}
}

function do_deploy {
    echo "No deploy"
}

function do_entry {
    /bin/bash
}

function do_add_auth {
    [ $# -eq 3 ] || (echo "add_auth: wrong argument numbers")
    echo "machine ${1} login ${2} password ${3}" >> ${HOME}/.netrc
}

shift

sudo chown $(id -u):$(id -g) ${DOCKER_WORK_DIR}

case $CMD in
     #here is a hack. please be aware
     "all")
        do_add_auth $@
        shift 3
        do_repo_init $@
        shift 2
        do_repo_sync
        do_build
        do_deploy $@
        ;;
    "add_auth")
        do_add_auth $@
        ;;
    "entry")
        do_entry $@
        ;;
    "init")
        do_repo_init $@
        ;;
    "sync")
        do_repo_sync
        ;;
    "fetch")
        do_fetch
        ;;
    "build")
        do_build
        ;;
    "deploy")
        do_deploy
        ;;
    "help")
        usage
        ;;
esac



