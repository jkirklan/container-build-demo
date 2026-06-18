#!/bin/bash
# Build multi-architecture container images (linux/amd64, linux/arm64)
# Usage: ./build-multiarch.sh <containerfile-dir> <image-name:tag> [additional-podman-args...]
#
# Example: ./build-multiarch.sh sonarr ghcr.io/jkirklan/sonarr:latest
# Example: ./build-multiarch.sh . ghcr.io/jkirklan/demo:latest -f ubi/Containerfile

set -e

CONTAINER_DIR="${1:?Missing containerfile directory}"
IMAGE_NAME="${2:?Missing image name}"
shift 2
EXTRA_ARGS=("$@")  # Capture remaining arguments for podman build
MANIFEST_NAME="${IMAGE_NAME}"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=== Multi-Architecture Container Build ==="
echo "Directory: ${CONTAINER_DIR}"
echo "Manifest: ${MANIFEST_NAME}"
echo ""

# Remove old manifest if exists
podman manifest rm "${MANIFEST_NAME}" 2>/dev/null || true

# Create manifest
echo -e "${GREEN}Creating manifest...${NC}"
podman manifest create "${MANIFEST_NAME}"

# Build for amd64
echo -e "${GREEN}Building linux/amd64...${NC}"
podman build \
  --platform linux/amd64 \
  --manifest "${MANIFEST_NAME}" \
  -t "${IMAGE_NAME}-amd64" \
  "${EXTRA_ARGS[@]}" \
  "${CONTAINER_DIR}"

# Build for arm64
echo -e "${GREEN}Building linux/arm64...${NC}"
podman build \
  --platform linux/arm64 \
  --manifest "${MANIFEST_NAME}" \
  -t "${IMAGE_NAME}-arm64" \
  "${EXTRA_ARGS[@]}" \
  "${CONTAINER_DIR}"

# Inspect manifest
echo -e "${GREEN}Manifest contents:${NC}"
podman manifest inspect "${MANIFEST_NAME}" | grep -E "architecture|os"

echo ""
echo -e "${GREEN}✓ Multi-arch build complete${NC}"
echo ""
echo "To scan: trivy image ${MANIFEST_NAME}"
echo "To push: podman manifest push ${MANIFEST_NAME}"
