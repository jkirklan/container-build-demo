#!/bin/bash
# Simple HTTP server for reveal.js presentation
# Usage: ./serve.sh [port]

PORT="${1:-8080}"

echo "========================================="
echo "  Demo Presentation Server"
echo "========================================="
echo ""
echo "Starting HTTP server on port $PORT..."
echo ""
echo "Open in browser:"
echo "  → http://localhost:$PORT"
echo ""
echo "Press Ctrl+C to stop"
echo ""

cd "$(dirname "$0")"
python3 -m http.server "$PORT"
