#!/usr/bin/env bash

set -o errexit
set -o pipefail
set -o nounset

check_systemd() {
  if ! command -v systemctl >/dev/null 2>&1; then
    echo "Sorry! This script is specifically for Linux systems with systemd, like Ubuntu 16.04 and above."
    exit 1
  fi
}

check_root() {
  if [[ $(id -u) -ne 0 ]]; then
    echo "Root privileges required! Please run this script as root"
    exit 1
  fi
}

CLDBIN="/sbx/bin/sclone"
OSARCH=$(uname -m)
SCLVER="1.63"
TMPDIR="/sbx/temp"

installation() {
  DOMAIN="static.botbox.xyz"
  DL_URL="https://$DOMAIN/sclone-$SCLVER-$BINTAG.tar.gz"

  echo "Downloading sclone binary package..."
  if ! curl -L -o "$TMPDIR/sclone-$SCLVER-$BINTAG" "$DL_URL" | sudo bash; then
    echo "Failed to download sclone binary package"
    exit 1
  fi

  echo "Extracting sclone binary package..."
  tar xvzf "$TMPDIR/sclone-$SCLVER-$BINTAG" --strip-components=1 -C "$TMPDIR/sclone"

  echo "Installing sclone..."
  if ! mv "$TMPDIR/sclone" "$CLDBIN"; then
    echo "Failed to install sclone"
    exit 1
  fi

  echo "Cleaning up..."
  rm "$TMPDIR/sclone-$SCLVER-$BINTAG"

  chmod 0775 "$CLDBIN"

  sclone_version=$(sclone version | awk 'NR==1 {print $2}' | cut -c-12)
  echo "sclone $sclone_version has been installed successfully"
}

check_root
check_systemd

case $OSARCH in
  x86_64)
    BINTAG=amd64
    installation
    ;;
  arm*)
    BINTAG=arm
    installation
    ;;
  arm64)
    BINTAG=arm
    installation
    ;;
  *)
    echo "Unsupported OSARCH: $OSARCH"
    exit 1
    ;;
esac
