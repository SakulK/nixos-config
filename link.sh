#!/usr/bin/env bash

set -e
dir=$(pwd)

select file in $(ls ./hosts)
do
    ln -fs "${dir}/hosts/${file}" /etc/nixos/configuration.nix
    break
done