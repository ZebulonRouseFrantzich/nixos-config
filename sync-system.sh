#!/bin/sh

# Script to synchronize system state
# with configuration files for nixos system
# and home-manager

echo 'Starting system sync!!'

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )

# Rebuild system
sudo nixos-rebuild switch --flake $SCRIPT_DIR#system;

echo 'Finished system sync!!'
echo ''
