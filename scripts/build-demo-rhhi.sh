#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEMO_DIR="$(dirname "$SCRIPT_DIR")"
HOMELAB_ROOT="$(dirname "$DEMO_DIR")"

echo "=== Building Demo Images (RHHI) ==="
echo "Demo directory: $DEMO_DIR"
echo ""

# Build webapp (build context is webapp/, Containerfile is in rhhi/ subdirectory)
echo "📦 Building webapp (RHHI)..."
cd "$DEMO_DIR/webapp"
"$HOMELAB_ROOT/containerfiles/build-multiarch.sh" . ghcr.io/jkirklan/demo-webapp-rhhi:latest -f rhhi/Containerfile

echo ""
echo "📦 Building database (build context is database/, Containerfile is in rhhi/ subdirectory)..."
cd "$DEMO_DIR/database"
"$HOMELAB_ROOT/containerfiles/build-multiarch.sh" . ghcr.io/jkirklan/demo-db-rhhi:latest -f rhhi/Containerfile

echo ""
echo "=== Scanning Images ==="
"$SCRIPT_DIR/scan-demo.sh" rhhi

echo ""
echo "✅ RHHI demo images built and scanned successfully"
echo ""
echo "Images created:"
echo "  - ghcr.io/jkirklan/demo-webapp-rhhi:latest"
echo "  - ghcr.io/jkirklan/demo-db-rhhi:latest"
