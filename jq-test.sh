#!/bin/bash
LAMBDA_NS="blaze"
STAGE_KEY="dev"
NORM_PREFIX="${LAMBDA_NS}-${STAGE_KEY}-lambda-edge-normalize-params-"
# fake AWS output
cat << 'JSON' | jq -r ".[] | select(startswith(\"${NORM_PREFIX}\"))" | tail -n 1
[
  "blaze-dev-lambda-edge-normalize-params-deadbeef",
  "blaze-dev-lambda-edge-normalize-params-a0d6b12d"
]
JSON
