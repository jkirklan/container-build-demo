#!/bin/bash
set -e

VARIANT="${1:-all}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEMO_DIR="$(dirname "$SCRIPT_DIR")"

echo "=== Cleaning up Demo ($VARIANT) ==="
echo ""

cleanup_variant() {
  local var=$1

  echo "🛑 Stopping $var services..."
  sudo systemctl stop demo-webapp-${var}.service 2>/dev/null || true
  sudo systemctl stop demo-db-${var}.service 2>/dev/null || true

  echo "🗑️  Removing $var quadlets..."
  sudo rm -f /etc/containers/systemd/demo-*-${var}.container

  echo "✅ $var services cleaned up"
}

if [ "$VARIANT" = "all" ]; then
  cleanup_variant "ubi"
  cleanup_variant "rhhi"

  echo ""
  echo "🗑️  Removing network quadlet..."
  sudo rm -f /etc/containers/systemd/demo-network.network

  echo ""
  echo "🌐 Removing demo-net network..."
  podman network rm demo-net 2>/dev/null || true

elif [ "$VARIANT" = "ubi" ] || [ "$VARIANT" = "rhhi" ]; then
  cleanup_variant "$VARIANT"
else
  echo "❌ Invalid variant: $VARIANT"
  echo "Usage: $0 [ubi|rhhi|all]"
  exit 1
fi

echo ""
echo "🔄 Reloading systemd daemon..."
sudo systemctl daemon-reload

echo ""
echo "✅ Demo cleaned up"
echo ""
echo "Note: Data directories preserved at /home/jkirklan/demo-data/"
echo "      Podman secret 'demo-postgres-password' preserved"
echo ""
echo "To remove data:"
echo "  rm -rf /home/jkirklan/demo-data/"
echo ""
echo "To remove secret:"
echo "  podman secret rm demo-postgres-password"
