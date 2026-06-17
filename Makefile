# Demo Container Build Automation
# Usage: make build-ubi, make build-rhhi, make build-all

.PHONY: help build-ubi build-rhhi build-all scan-ubi scan-rhhi deploy-ubi deploy-rhhi test-ubi test-rhhi clean

help:
	@echo "Demo Build Automation"
	@echo ""
	@echo "Build Commands:"
	@echo "  make build-ubi     - Build UBI images"
	@echo "  make build-rhhi    - Build RHHI images"
	@echo "  make build-all     - Build both UBI and RHHI"
	@echo ""
	@echo "Scan Commands:"
	@echo "  make scan-ubi      - Scan UBI images (security)"
	@echo "  make scan-rhhi     - Scan RHHI images (security)"
	@echo ""
	@echo "Deploy Commands:"
	@echo "  make deploy-ubi    - Deploy UBI stack"
	@echo "  make deploy-rhhi   - Deploy RHHI stack"
	@echo ""
	@echo "Test Commands:"
	@echo "  make test-ubi      - Test UBI stack"
	@echo "  make test-rhhi     - Test RHHI stack"
	@echo ""
	@echo "Full Pipelines:"
	@echo "  make ubi           - Build + Scan + Deploy + Test (UBI)"
	@echo "  make rhhi          - Build + Scan + Deploy + Test (RHHI)"
	@echo "  make all           - Full pipeline for both"
	@echo ""
	@echo "Cleanup:"
	@echo "  make clean         - Remove all demo containers and data"

# Build targets
build-ubi:
	@echo "🔨 Building UBI images..."
	./scripts/build-demo-ubi.sh

build-rhhi:
	@echo "🔨 Building RHHI images..."
	./scripts/build-demo-rhhi.sh

build-all: build-ubi build-rhhi

# Scan targets
scan-ubi:
	@echo "🔍 Scanning UBI images..."
	./scripts/scan-demo.sh ubi

scan-rhhi:
	@echo "🔍 Scanning RHHI images..."
	./scripts/scan-demo.sh rhhi

# Deploy targets
deploy-ubi:
	@echo "🚀 Deploying UBI stack..."
	./scripts/deploy-demo-ubi.sh

deploy-rhhi:
	@echo "🚀 Deploying RHHI stack..."
	./scripts/deploy-demo-rhhi.sh

# Test targets
test-ubi:
	@echo "✅ Testing UBI stack..."
	./scripts/demo-tests.sh ubi

test-rhhi:
	@echo "✅ Testing RHHI stack..."
	./scripts/demo-tests.sh rhhi

# Full pipelines
ubi: build-ubi scan-ubi deploy-ubi test-ubi
	@echo "✅ UBI pipeline complete!"

rhhi: build-rhhi scan-rhhi deploy-rhhi test-rhhi
	@echo "✅ RHHI pipeline complete!"

all: ubi rhhi
	@echo "✅ All pipelines complete!"

# Cleanup
clean:
	@echo "🧹 Cleaning up demo environment..."
	./scripts/cleanup-demo.sh all
