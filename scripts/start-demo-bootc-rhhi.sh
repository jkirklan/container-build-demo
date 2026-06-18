#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEMO_DIR="$(dirname "$SCRIPT_DIR")"

echo "🚀 Starting RHHI bootc demo instance as container..."
echo ""
echo "ℹ️  Note: bootc images are designed to boot as full OS instances."
echo "   This script runs the bootc image as a container for demonstration."
echo "   For true bootc deployment, boot the image on bare metal or VM."
echo ""

# Check if image exists
if ! podman image exists ghcr.io/jkirklan/demo-bootc-rhhi:latest; then
    echo "❌ Error: RHHI bootc image not found"
    echo "Run 'make build-bootc-rhhi' first"
    exit 1
fi

# Create network if it doesn't exist
if ! podman network exists demo-net; then
    echo "📡 Creating demo-net network..."
    podman network create demo-net
fi

# Start bootc container
echo "🖥️  Starting RHHI bootc instance as container..."
podman run -d \
    --name demo-bootc-rhhi \
    --network demo-net \
    -p 3004:3000 \
    ghcr.io/jkirklan/demo-bootc-rhhi:latest

# Wait for instance to start
echo "⏳ Waiting for instance to start..."
sleep 5

# Check if running
if podman ps | grep -q demo-bootc-rhhi; then
    echo ""
    echo "✅ RHHI bootc demo instance started successfully!"
    echo ""
    echo "📍 Access points:"
    echo "   Web UI: http://localhost:3004"
    echo "   Health: http://localhost:3004/health"
    echo ""
    echo "ℹ️  This bootc image includes:"
    echo "   - Built-in application (no separate containers)"
    echo "   - Minimal immutable OS (Fedora-based)"
    echo "   - Systemd-managed services"
    echo ""
    echo "🔍 Check status:"
    echo "   podman ps --filter name=demo-bootc-rhhi"
    echo ""
    echo "🛑 Stop instance:"
    echo "   podman stop demo-bootc-rhhi && podman rm demo-bootc-rhhi"
else
    echo "❌ Error: Failed to start instance"
    echo "Check logs with: podman logs demo-bootc-rhhi"
    exit 1
fi
