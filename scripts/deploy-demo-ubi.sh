#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEMO_DIR="$(dirname "$SCRIPT_DIR")"

# Detect OS and set appropriate paths
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS
  DATA_DIR="$HOME/demo-data"
  SYSTEMD_DIR="$HOME/.config/containers/systemd"
  USE_SUDO=""
  echo "⚠️  Detected macOS - using rootless Podman deployment"
  echo "⚠️  For full systemd integration, deploy to Linux server"
  echo ""
else
  # Linux
  DATA_DIR="/home/$(whoami)/demo-data"
  SYSTEMD_DIR="/etc/containers/systemd"
  USE_SUDO="sudo"
fi

echo "=== Deploying Demo (UBI) ==="
echo ""

# Create Podman secret if doesn't exist
if ! podman secret exists demo-postgres-password; then
  echo "🔐 Creating demo-postgres-password secret..."
  echo -n "demopassword123" | podman secret create demo-postgres-password -
  echo "✅ Secret created"
else
  echo "✅ Secret demo-postgres-password already exists"
fi

echo ""
echo "📁 Creating data directories..."
mkdir -p "$DATA_DIR/ubi/postgres"
echo "✅ Data directories created: $DATA_DIR/ubi/postgres"

echo ""
echo "📋 Copying quadlets to systemd directory..."
mkdir -p "$SYSTEMD_DIR"

# Copy network (no changes needed)
cp "$DEMO_DIR/quadlets/demo-network.network" "$SYSTEMD_DIR/"

# Patch quadlets to use correct data directory path
if [[ "$OSTYPE" == "darwin"* ]]; then
  # macOS: Replace /home/jkirklan with $HOME
  sed "s|/home/jkirklan|$HOME|g" "$DEMO_DIR/quadlets/demo-db-ubi.container" > "$SYSTEMD_DIR/demo-db-ubi.container"
  sed "s|/home/jkirklan|$HOME|g" "$DEMO_DIR/quadlets/demo-webapp-ubi.container" > "$SYSTEMD_DIR/demo-webapp-ubi.container"
else
  # Linux: Use as-is
  cp "$DEMO_DIR/quadlets/demo-db-ubi.container" "$SYSTEMD_DIR/"
  cp "$DEMO_DIR/quadlets/demo-webapp-ubi.container" "$SYSTEMD_DIR/"
fi

echo "✅ Quadlets copied to $SYSTEMD_DIR"

echo ""
echo "🔄 Reloading systemd daemon..."
$USE_SUDO systemctl daemon-reload || systemctl --user daemon-reload

echo ""
echo "🌐 Creating demo-net network..."
podman network create demo-net || echo "Network already exists"

echo ""
echo "🚀 Starting database..."
$USE_SUDO systemctl start demo-db-ubi.service || systemctl --user start demo-db-ubi.service

echo "⏳ Waiting 15 seconds for database initialization..."
sleep 15

echo ""
echo "🚀 Starting web app..."
$USE_SUDO systemctl start demo-webapp-ubi.service || systemctl --user start demo-webapp-ubi.service

echo "⏳ Waiting 5 seconds for app startup..."
sleep 5

echo ""
echo "✅ Demo deployed (UBI)"
echo ""
echo "Services:"
echo "  - Database: demo-db-ubi (port 5432)"
echo "  - Web App:  demo-webapp-ubi (port 3000)"
echo ""

if [[ "$OSTYPE" == "darwin"* ]]; then
  echo "Check status (macOS rootless):"
  echo "  systemctl --user status demo-db-ubi"
  echo "  systemctl --user status demo-webapp-ubi"
  echo "  podman ps"
else
  echo "Check status (Linux):"
  echo "  sudo systemctl status demo-db-ubi"
  echo "  sudo systemctl status demo-webapp-ubi"
fi

echo ""
echo "Test locally:"
echo "  curl http://localhost:3000/health"
echo "  curl http://localhost:3000/api/tasks"
echo ""

if [[ "$OSTYPE" != "darwin"* ]]; then
  echo "Next steps (Linux deployment):"
  echo "  1. Add DNS record: ipa dnsrecord-add lab.kubelet.org demo-ubi --a-rec=192.168.1.150"
  echo "  2. Add Traefik route: deploy traefik/demo-routes.yml"
  echo "  3. Access: https://demo-ubi.lab.kubelet.org"
fi
