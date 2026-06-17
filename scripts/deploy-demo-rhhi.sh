#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEMO_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== Deploying Demo (RHHI) ==="
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
mkdir -p /home/jkirklan/demo-data/rhhi/postgres
echo "✅ Data directories created"

echo ""
echo "📋 Copying quadlets to systemd directory..."
sudo cp "$DEMO_DIR/quadlets/demo-network.network" /etc/containers/systemd/
sudo cp "$DEMO_DIR/quadlets/demo-db-rhhi.container" /etc/containers/systemd/
sudo cp "$DEMO_DIR/quadlets/demo-webapp-rhhi.container" /etc/containers/systemd/

echo ""
echo "🔄 Reloading systemd daemon..."
sudo systemctl daemon-reload

echo ""
echo "🌐 Creating demo-net network..."
podman network create demo-net || echo "Network already exists"

echo ""
echo "🚀 Starting database..."
sudo systemctl start demo-db-rhhi.service

echo "⏳ Waiting 15 seconds for database initialization..."
sleep 15

echo ""
echo "🚀 Starting web app..."
sudo systemctl start demo-webapp-rhhi.service

echo "⏳ Waiting 5 seconds for app startup..."
sleep 5

echo ""
echo "✅ Demo deployed (RHHI)"
echo ""
echo "Services:"
echo "  - Database: demo-db-rhhi (port 5433)"
echo "  - Web App:  demo-webapp-rhhi (port 3001)"
echo ""
echo "Check status:"
echo "  sudo systemctl status demo-db-rhhi"
echo "  sudo systemctl status demo-webapp-rhhi"
echo ""
echo "Test locally:"
echo "  curl http://localhost:3001/health"
echo "  curl http://localhost:3001/api/tasks"
echo ""
echo "Next steps:"
echo "  1. Add DNS record: ipa dnsrecord-add lab.kubelet.org demo-rhhi --a-rec=192.168.1.150"
echo "  2. Add Traefik route: deploy traefik/demo-routes.yml"
echo "  3. Access: https://demo-rhhi.lab.kubelet.org"
