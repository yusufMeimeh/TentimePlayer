#!/bin/bash

if [ $# -ne 2 ]; then
  echo "Usage: $0 <xcresult> <output>"
  exit 1
fi

XCRESULT=$1
OUTPUT=$2

xccov view --report --json $XCRESULT > coverage.json

jq -r '.targets[] | select(.name | endswith("Tests")) | .files[]? | select(.name | endswith(".swift")) | {name: .name, coverage: [.lineCoverage[]? | {line: .line, hits: .count}]}' coverage.json | jq -s '{files: .}' > $OUTPUT

rm coverage.json

