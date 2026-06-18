#!/usr/bin/env bash
set -euo pipefail

# Start the demo dashboard server
# Requires Node.js 18+

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================="
echo "  Starting Demo Dashboard"
echo "========================================="
echo ""

# Check if node_modules exists
if [[ ! -d "$SCRIPT_DIR/node_modules" ]]; then
  echo "Installing dependencies..."
  cd "$SCRIPT_DIR"
  npm install
  echo ""
fi

# Ensure required directories exist
mkdir -p "$SCRIPT_DIR/status" "$SCRIPT_DIR/../logs"

# Start server
cd "$SCRIPT_DIR"
exec node server.js
