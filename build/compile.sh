#!/usr/bin/env bash

set -euo pipefail

if [ -z "$1" ]; then
    echo "Usage: $0 <output_folder>"
    exit 1
fi

# Create output folder if it does not exist
mkdir -p "$1/registry"
mkdir -p "$1/funding_round"
mkdir -p "$1/idea"

# Compile contracts
ligo compile contract ../src/interface/registry.mligo > "$1/registry/registry.tz"
ligo compile contract ../src/interface/funding_round.mligo > "$1/funding_round/funding_roumd.tz"
ligo compile contract ../src/interface/idea.mligo > "$1/idea/idea.tz"

