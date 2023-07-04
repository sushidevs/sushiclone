#!/usr/bin/bash

set -o errexit
set -o pipefail
set -o nounset

checkRoot() {
  if [[ $EUID -eq 0 ]]; then
    printf "%s"
  else
    echo "::: Permission Denied! Please execute as root."
    sleep 1
    echo "::: Exiting..."
    exit 1
  fi
}

checkSystemd() {
  if ! command -v systemctl >/dev/null 2>&1; then
    echo -e "::: Linux with systemd required (Ubuntu 16.04+)"
    sleep 1
    echo "::: Exiting..."
    exit 1
  fi
}

installation() {
  CLDBIN="/sbx/bin/sclone"
  SCLVER="1.63"
  TMPDIR="/sbx/temp"
  DL_URL="https://static.botbox.xyz/sclone-$SCLVER-$BINTAG.tar.gz"

  echo "Downloading sclone binary package..."
  if ! curl -L -o "$TMPDIR/sclone-$SCLVER-$BINTAG.tar.gz" "$DL_URL"; then
    echo "Failed to download sclone binary package"
    exit 1
  fi

  echo "Extracting sclone binary package..."
  tar xvzf "$TMPDIR/sclone-$SCLVER-$BINTAG.tar.gz" -C "$TMPDIR/" >/dev/null 2>&1

  echo "Installing sclone..."
  if ! mv "$TMPDIR/sclone-$SCLVER-$BINTAG" "$CLDBIN"; then
    echo "Failed to install sclone"
    exit 1
  fi

  echo "Cleaning up..."
  rm -rf "$TMPDIR/sclone-$SCLVER-$BINTAG.tar.gz"

  chmod 0775 "$CLDBIN"

  sclone_version=$(sclone version | awk 'NR==1 {print $2}' | cut -c-12)
  echo "sclone $sclone_version has been installed successfully"
}

checkRoot
checkSystemd

case $(uname -m) in
  x86_64  ) BINTAG="amd64"; installation ;;
  arm*    ) BINTAG="arm"; installation ;;
  arm64   ) BINTAG="arm"; installation ;;
  *       ) echo "Unsupported OS architecture: $(uname -m)"; exit 1 ;;
esac
