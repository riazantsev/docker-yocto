#!/bin/sh

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
    [ -a $WORK_DIR/.repo ] || echo "repo was not init for workdir. Use 'init' first" && exit 1
    $REPO sync
}

function do_build_init {
    [ -z $DOCKER_BUILD_DIR ] && DOCKER_BUILD_DIR=build
    OLD_DIR=`pwd`
    . poky/oe-init-build-env ${DOCKER_BUILD_DIR}
    cp ${OLD_DIR}/pana/meta-pana/conf/bblayers.conf.sample.${MACHINE} ./conf/bblayers.conf
    cp ${OLD_DIR}/pana/meta-pana/conf/local.conf.sample.${MACHINE} ./conf/local.conf
    sed -ie "s/BSPROOT =.*/BSPROOT = \"${OLD_DIR}\"/g" ./conf/bblayers.conf
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

shift

case $CMD in
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



