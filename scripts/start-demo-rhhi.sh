#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEMO_DIR="$(dirname "$SCRIPT_DIR")"

echo "🚀 Starting RHHI demo instances..."
echo ""

# Check if images exist
if ! podman image exists ghcr.io/jkirklan/demo-webapp-rhhi:latest; then
    echo "❌ Error: RHHI webapp image not found"
    echo "Run 'make build-rhhi' first"
    exit 1
fi

if ! podman image exists ghcr.io/jkirklan/demo-db-rhhi:latest; then
    echo "❌ Error: RHHI database image not found"
    echo "Run 'make build-rhhi' first"
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
echo "🗄️  Starting PostgreSQL database (RHHI)..."
podman run -d \
    --name demo-db-rhhi \
    --network demo-net \
    -p 5433:5432 \
    --secret demo-postgres-password,type=env,target=POSTGRES_PASSWORD \
    -e POSTGRES_DB=taskdb \
    -e POSTGRES_USER=taskuser \
    ghcr.io/jkirklan/demo-db-rhhi:latest

# Wait for database to be ready
echo "⏳ Waiting for database to be ready..."
sleep 10

# Start webapp
echo "📱 Starting web application (RHHI)..."
podman run -d \
    --name demo-webapp-rhhi \
    --network demo-net \
    -p 3002:3000 \
    -e POSTGRES_HOST=demo-db-rhhi \
    -e POSTGRES_PORT=5432 \
    -e POSTGRES_DB=taskdb \
    -e POSTGRES_USER=taskuser \
    --secret demo-postgres-password,type=env,target=POSTGRES_PASSWORD \
    ghcr.io/jkirklan/demo-webapp-rhhi:latest

# Wait for webapp to start
echo "⏳ Waiting for webapp to start..."
sleep 5

# Check if running
if podman ps | grep -q demo-webapp-rhhi && podman ps | grep -q demo-db-rhhi; then
    echo ""
    echo "✅ RHHI demo instances started successfully!"
    echo ""
    echo "📍 Access points:"
    echo "   Web UI: http://localhost:3002"
    echo "   Health: http://localhost:3002/health"
    echo ""
    echo "🔍 Check status:"
    echo "   podman ps --filter name=demo-.*-rhhi"
    echo ""
    echo "🛑 Stop instances:"
    echo "   podman stop demo-webapp-rhhi demo-db-rhhi"
    echo "   podman rm demo-webapp-rhhi demo-db-rhhi"
else
    echo "❌ Error: Failed to start instances"
    echo "Check logs with: podman logs demo-webapp-rhhi"
    exit 1
fi
