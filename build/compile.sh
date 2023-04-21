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
mkdir -p "$1/promotion_vote"
mkdir -p "$1/proposal_vote"

# Compile promotion and proposal votes
ligo compile contract ../src/interface/promotion_vote.mligo -e main > "$1/promotion_vote/promotion_vote.tz"
ligo compile contract ../src/interface/proposal_vote.mligo -e main > "$1/proposal_vote/proposal_vote.tz"

# Compile registry
ligo compile contract ../src/interface/registry.mligo -e main > "$1/registry/registry.tz"

# Compile funding and funding factory
ligo compile contract ../src/interface/funding_round.mligo -e main > ../src/factory/dummy.tz
cp ../src/factory/factory_funding_round_storage.mligo ../src/factory/dummy_storage.tz
ligo compile contract ../src/factory/factory.mligo -e build > "$1/funding_round/factory_funding_round.tz"
rm ../src/factory/dummy.tz
rm ../src/factory/dummy_storage.tz

# Compile idea
ligo compile contract ../src/interface/idea.mligo -e main > ../src/factory/dummy.tz
cp ../src/factory/factory_idea_storage.mligo ../src/factory/dummy_storage.tz
ligo compile contract ../src/factory/factory.mligo -e build > "$1/idea/factory_idea.tz"
rm ../src/factory/dummy.tz
rm ../src/factory/dummy_storage.tz



