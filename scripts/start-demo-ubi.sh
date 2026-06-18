#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEMO_DIR="$(dirname "$SCRIPT_DIR")"

echo "🚀 Starting UBI demo instances..."
echo ""

# Check if images exist
if ! podman image exists ghcr.io/jkirklan/demo-webapp-ubi:latest; then
    echo "❌ Error: UBI webapp image not found"
    echo "Run 'make build-ubi' first"
    exit 1
fi

if ! podman image exists ghcr.io/jkirklan/demo-db-ubi:latest; then
    echo "❌ Error: UBI database image not found"
    echo "Run 'make build-ubi' first"
    exit 1
fi

# Create network if it doesn't exist
if ! podman network exists demo-net; then
    echo "📡 Creating demo-net network..."
    podman network create demo-net
fi

# Create secret if it doesn't exist
if ! podman secret exists demo-postgres-password; then
    echo "🔐 Creating database password secret..."
    echo -n "demopassword123" | podman secret create demo-postgres-password -
fi

# Start database
echo "🗄️  Starting PostgreSQL database (UBI)..."
podman run -d \
    --name demo-db-ubi \
    --network demo-net \
    -p 5432:5432 \
    --secret demo-postgres-password,type=env,target=POSTGRES_PASSWORD \
    -e POSTGRES_DB=taskdb \
    -e POSTGRES_USER=taskuser \
    ghcr.io/jkirklan/demo-db-ubi:latest

# Wait for database to be ready
echo "⏳ Waiting for database to be ready..."
sleep 10

# Start webapp
echo "📱 Starting web application (UBI)..."
podman run -d \
    --name demo-webapp-ubi \
    --network demo-net \
    -p 3001:3000 \
    -e POSTGRES_HOST=demo-db-ubi \
    -e POSTGRES_PORT=5432 \
    -e POSTGRES_DB=taskdb \
    -e POSTGRES_USER=taskuser \
    --secret demo-postgres-password,type=env,target=POSTGRES_PASSWORD \
    ghcr.io/jkirklan/demo-webapp-ubi:latest

# Wait for webapp to be ready
echo "⏳ Waiting for webapp to start..."
sleep 5

# Check if running
if podman ps | grep -q demo-webapp-ubi && podman ps | grep -q demo-db-ubi; then
    echo ""
    echo "✅ UBI demo instances started successfully!"
    echo ""
    echo "📍 Access points:"
    echo "   Web UI: http://localhost:3001"
    echo "   Health: http://localhost:3001/health"
    echo ""
    echo "🔍 Check status:"
    echo "   podman ps --filter name=demo-.*-ubi"
    echo ""
    echo "🛑 Stop instances:"
    echo "   podman stop demo-webapp-ubi demo-db-ubi"
    echo "   podman rm demo-webapp-ubi demo-db-ubi"
else
    echo "❌ Error: Failed to start instances"
    echo "Check logs with: podman logs demo-webapp-ubi"
    exit 1
fi
