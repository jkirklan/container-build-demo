#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEMO_DIR="$(dirname "$SCRIPT_DIR")"

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
mkdir -p /home/jkirklan/demo-data/ubi/postgres
echo "✅ Data directories created"

echo ""
echo "📋 Copying quadlets to systemd directory..."
sudo cp "$DEMO_DIR/quadlets/demo-network.network" /etc/containers/systemd/
sudo cp "$DEMO_DIR/quadlets/demo-db-ubi.container" /etc/containers/systemd/
sudo cp "$DEMO_DIR/quadlets/demo-webapp-ubi.container" /etc/containers/systemd/

echo ""
echo "🔄 Reloading systemd daemon..."
sudo systemctl daemon-reload

echo ""
echo "🌐 Creating demo-net network..."
podman network create demo-net || echo "Network already exists"

echo ""
echo "🚀 Starting database..."
sudo systemctl start demo-db-ubi.service

echo "⏳ Waiting 15 seconds for database initialization..."
sleep 15

echo ""
echo "🚀 Starting web app..."
sudo systemctl start demo-webapp-ubi.service

echo "⏳ Waiting 5 seconds for app startup..."
sleep 5

echo ""
echo "✅ Demo deployed (UBI)"
echo ""
echo "Services:"
echo "  - Database: demo-db-ubi (port 5432)"
echo "  - Web App:  demo-webapp-ubi (port 3000)"
echo ""
echo "Check status:"
echo "  sudo systemctl status demo-db-ubi"
echo "  sudo systemctl status demo-webapp-ubi"
echo ""
echo "Test locally:"
echo "  curl http://localhost:3000/health"
echo "  curl http://localhost:3000/api/tasks"
echo ""
echo "Next steps:"
echo "  1. Add DNS record: ipa dnsrecord-add lab.kubelet.org demo-ubi --a-rec=192.168.1.150"
echo "  2. Add Traefik route: deploy traefik/demo-routes.yml"
echo "  3. Access: https://demo-ubi.lab.kubelet.org"
