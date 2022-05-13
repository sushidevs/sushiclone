#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

if ! command -v systemctl >/dev/null 2>&1; then
    echo "Sorry! This script is only for Linux with systemd, eg: Ubuntu 16.04 and later..."
    exit 1
fi

if [[ $(id -u) -ne 0 ]]; then
    echo "This script must be run as root" 
    exit 1
fi

CLDBIN=/usr/bin/sclone
OSARCH=$(uname -m)
case $OSARCH in 
    x86_64)
        BINTAG=linux-amd64
        ;;
    i*86)
        BINTAG=linux-386
        ;;
    arm64)
        BINTAG=linux-arm64
        ;;
    arm*)
        BINTAG=linux-arm
        ;;
    *)
        echo "unsupported OSARCH: $OSARCH"
        exit 1
        ;;
esac

curl -L -O https://github.com/SUSHIB0X/SUSHICLONE/raw/main/sushiclone.tar.gz | sudo bash
tar xvzf sushiclone.tar.gz -C /sbx/bin
rm -rf sushiclone.tar.gz
chmod 0775 ${CLDBIN}

version=$(sclone version | head -1 | awk '{print $2}' | cut -c-12)
echo "sclone $version"
