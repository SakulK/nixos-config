#!/usr/bin/env bash

set -e
dir=$(pwd)

ln -fs "${dir}/configuration.nix" /etc/nixos/configuration.nix
