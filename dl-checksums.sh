#!/usr/bin/env sh

# Credit to https://github.com/andrewrothstein

set -e
DIR=/tmp
APPNAME=wkhtmltox
MIRROR=https://github.com/wkhtmltopdf/packaging/releases/download
VERSION=0.12.6-1

ODOO_APPNAME=odoo
ODOO_VERSION=14.0
ODOO_RELEASE=20201218
MIRROR2=http://nightly.odoo.com

dl() {
    local ver=$1
    local os=$2
    local arch=$3
    local suffix=${4:-deb}
    local platform="${os}_${arch}"
    local file="${APPNAME}_${ver}.${platform}.${suffix}"
    local url=$MIRROR/$ver/$file
    local lfile=$DIR/$file
    if [ ! -e $lfile ]; then
        wget -q -O $lfile $url
    fi
    echo $(sha1sum $lfile | awk '{print $1}')"  "$file
}

dl2() {
    local ver=$1
    local release=$2
    local suffix=deb
    local platform="all"
    local file="${ODOO_APPNAME}_${ver}.${release}_${platform}.${suffix}"
    local url=$MIRROR2/$ver/nightly/deb/$file
    local lfile=$DIR/$file
    if [ ! -e $lfile ]; then
        wget -q -O $lfile $url
    fi
    echo $(sha1sum $lfile | awk '{print $1}')"  "${ODOO_APPNAME}.${suffix}
}

dl_ver() {
    local ver=$1
    local release=$2
    dl $VERSION buster amd64
    dl $VERSION buster arm64
    dl $VERSION raspberrypi.buster armhf
    dl2 $ver $release
}

dl_ver ${1:-$ODOO_VERSION} ${2:-$ODOO_RELEASE}
