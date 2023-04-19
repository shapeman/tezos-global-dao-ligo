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
mkdir -p "$1/factory"

# Compile registry
ligo compile contract ../src/interface/registry.mligo -e main > "$1/registry/registry.tz"

# Compile funding and funding factory
ligo compile contract ../src/interface/funding_round.mligo -e main > ../src/factory/dummy.tz
ligo compile contract ../src/factory/factory.mligo -e build > "$1/funding_round/factory_funding_round.tz"
# rm ../src/factory/dummy.tz

# Compile idea
ligo compile contract ../src/interface/idea.mligo -e main > "$1/idea/idea.tz"

