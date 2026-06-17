#!/bin/bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEMO_DIR="$(dirname "$SCRIPT_DIR")"
REMOTE_HOST="kvm151.lab.kubelet.org"
REMOTE_USER="jkirklan"

# Deployment type: ubi or rhhi
DEPLOY_TYPE="${1:-ubi}"

if [[ "$DEPLOY_TYPE" != "ubi" && "$DEPLOY_TYPE" != "rhhi" ]]; then
  echo "Usage: $0 [ubi|rhhi]"
  echo "  ubi  - Deploy UBI-based demo (default)"
  echo "  rhhi - Deploy RHHI-based demo"
  exit 1
fi

echo "=== Deploying Demo ($DEPLOY_TYPE) to kvm151 ==="
echo ""

# Copy quadlets to kvm151
echo "📋 Copying quadlets to kvm151..."
scp "$DEMO_DIR/quadlets/demo-network.network" \
    "$DEMO_DIR/quadlets/demo-db-${DEPLOY_TYPE}.container" \
    "$DEMO_DIR/quadlets/demo-webapp-${DEPLOY_TYPE}.container" \
    ${REMOTE_USER}@${REMOTE_HOST}:/tmp/

echo ""
echo "🚀 Deploying on kvm151..."
ssh ${REMOTE_USER}@${REMOTE_HOST} bash <<EOF
set -e

DEPLOY_TYPE="${DEPLOY_TYPE}"

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
mkdir -p /home/jkirklan/demo-data/${DEPLOY_TYPE}/postgres
echo "✅ Data directories created"

echo ""
echo "📋 Installing quadlets..."
mkdir -p /home/jkirklan/.config/containers/systemd
cp /tmp/demo-network.network /home/jkirklan/.config/containers/systemd/
cp /tmp/demo-db-${DEPLOY_TYPE}.container /home/jkirklan/.config/containers/systemd/
cp /tmp/demo-webapp-${DEPLOY_TYPE}.container /home/jkirklan/.config/containers/systemd/

echo ""
echo "🔄 Reloading systemd daemon..."
systemctl --user daemon-reload

echo ""
echo "🚀 Starting database..."
systemctl --user start demo-db-${DEPLOY_TYPE}.service

echo "⏳ Waiting 15 seconds for database initialization..."
sleep 15

echo ""
echo "🚀 Starting web app..."
systemctl --user start demo-webapp-${DEPLOY_TYPE}.service

echo "⏳ Waiting 5 seconds for app startup..."
sleep 5

echo ""
echo "✅ Demo deployed (${DEPLOY_TYPE}) on kvm151"
echo ""
echo "Services:"
echo "  - Database: demo-db-${DEPLOY_TYPE} (port 5432)"
echo "  - Web App:  demo-webapp-${DEPLOY_TYPE} (port 3000 or 3001)"
echo ""
echo "Check status:"
echo "  systemctl --user status demo-db-${DEPLOY_TYPE}"
echo "  systemctl --user status demo-webapp-${DEPLOY_TYPE}"
EOF

echo ""
echo "🌐 Next steps:"
echo "  1. Add DNS record:"
echo "     ssh kvm151.lab.kubelet.org 'kinit admin && ipa dnsrecord-add lab.kubelet.org demo-${DEPLOY_TYPE} --a-rec=192.168.1.150'"
echo ""
echo "  2. Add Traefik route (from local machine):"
echo "     # Add to infrastructure/config/traefik/dynamic.yml"
echo "     # Then: scp dynamic.yml services.lab.kubelet.org:/tmp/"
echo "     # ssh services 'sudo cp /tmp/dynamic.yml /etc/traefik/config/ && sudo systemctl reload traefik'"
echo ""
echo "  3. Test deployment:"
echo "     curl http://192.168.1.151:3000/health  # UBI"
echo "     curl http://192.168.1.151:3001/health  # RHHI"
echo ""
echo "  4. Access via Traefik:"
echo "     https://demo-${DEPLOY_TYPE}.lab.kubelet.org"
