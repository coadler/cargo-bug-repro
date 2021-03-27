#!/bin/bash

set -euo pipefail
cd "$(dirname "$0")"

echo "Building broken Dockerfile..."

docker build -t cargo-bug-broken -f Dockerfile.broken .
echo
echo "Should print 'Goodbye, world!'"
docker run --rm cargo-bug-broken /src/target/debug/cargo-bug-repro

echo
echo "Building fixed Dockerfile..."

docker build -t cargo-bug-fixed -f Dockerfile.fixed .
echo
echo "Should print 'Goodbye, world!'"
docker run --rm cargo-bug-fixed /src/target/debug/cargo-bug-repro
