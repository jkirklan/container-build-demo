#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEMO_DIR="$(dirname "$SCRIPT_DIR")"
HOMELAB_ROOT="$(dirname "$DEMO_DIR")"

echo "=== Building Demo Images (UBI) ==="
echo "Demo directory: $DEMO_DIR"
echo ""

# Build webapp (build context is webapp/, Containerfile is in ubi/ subdirectory)
echo "📦 Building webapp (UBI)..."
cd "$DEMO_DIR/webapp"
"$HOMELAB_ROOT/containerfiles/build-multiarch.sh" . ghcr.io/jkirklan/demo-webapp-ubi:latest -f ubi/Containerfile

echo ""
echo "📦 Building database (build context is database/, Containerfile is in ubi/ subdirectory)..."
cd "$DEMO_DIR/database"
"$HOMELAB_ROOT/containerfiles/build-multiarch.sh" . ghcr.io/jkirklan/demo-db-ubi:latest -f ubi/Containerfile

echo ""
echo "=== Scanning Images ==="
"$SCRIPT_DIR/scan-demo.sh" ubi

echo ""
echo "✅ UBI demo images built and scanned successfully"
echo ""
echo "Images created:"
echo "  - ghcr.io/jkirklan/demo-webapp-ubi:latest"
echo "  - ghcr.io/jkirklan/demo-db-ubi:latest"
