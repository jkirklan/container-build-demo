# Demo Container Build Automation - Three RHEL Deployment Tracks
# Usage: make build-ubi, make build-rhhi, make build-bootc, make demo

.PHONY: help build-ubi build-rhhi build-bootc build-all build-parallel scan-ubi scan-rhhi scan-bootc deploy-ubi deploy-rhhi test-ubi test-rhhi dashboard demo clean

help:
	@echo "Demo Build Automation - Three RHEL Deployment Tracks"
	@echo ""
	@echo "Build Commands:"
	@echo "  make build-ubi        - Build UBI images"
	@echo "  make build-rhhi       - Build RHHI images"
	@echo "  make build-bootc      - Build bootc image"
	@echo "  make build-all        - Build all three variants"
	@echo "  make build-parallel   - Build all in parallel (live demo)"
	@echo ""
	@echo "Scan Commands:"
	@echo "  make scan-ubi         - Scan UBI images (security)"
	@echo "  make scan-rhhi        - Scan RHHI images (security)"
	@echo "  make scan-bootc       - Scan bootc image (security)"
	@echo ""
	@echo "Deploy Commands:"
	@echo "  make deploy-ubi       - Deploy UBI stack"
	@echo "  make deploy-rhhi      - Deploy RHHI stack"
	@echo ""
	@echo "Test Commands:"
	@echo "  make test-ubi         - Test UBI stack"
	@echo "  make test-rhhi        - Test RHHI stack"
	@echo ""
	@echo "Full Pipelines:"
	@echo "  make ubi              - Build + Scan + Deploy + Test (UBI)"
	@echo "  make rhhi             - Build + Scan + Deploy + Test (RHHI)"
	@echo "  make bootc            - Build + Scan (bootc)"
	@echo "  make all              - Full pipeline for all variants"
	@echo ""
	@echo "Live Demo:"
	@echo "  make dashboard        - Start live dashboard server (port 8889)"
	@echo "  make demo             - Start dashboard + build all in parallel"
	@echo ""
	@echo "Cleanup:"
	@echo "  make clean            - Remove all demo containers and data"

# Build targets
build-ubi:
	@echo "🔨 Building UBI images..."
	./scripts/build-demo-ubi.sh

build-rhhi:
	@echo "🔨 Building RHHI images..."
	./scripts/build-demo-rhhi.sh

build-bootc:
	@echo "🔨 Building bootc image..."
	./scripts/build-demo-bootc.sh

build-all: build-ubi build-rhhi build-bootc

build-parallel:
	@echo "🔨 Building all variants in parallel..."
	./scripts/build-demo-parallel.sh

# Scan targets
scan-ubi:
	@echo "🔍 Scanning UBI images..."
	./scripts/scan-demo.sh ubi

scan-rhhi:
	@echo "🔍 Scanning RHHI images..."
	./scripts/scan-demo.sh rhhi

scan-bootc:
	@echo "🔍 Scanning bootc image..."
	./scripts/scan-demo.sh bootc

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

bootc: build-bootc scan-bootc
	@echo "✅ bootc pipeline complete!"

all: ubi rhhi bootc
	@echo "✅ All pipelines complete!"

# Live demo dashboard
dashboard:
	@echo "🎯 Starting live dashboard..."
	cd dashboard && ./start-dashboard.sh

demo:
	@echo "🚀 Starting live demo..."
	@echo "Starting dashboard in background..."
	cd dashboard && npm install && node server.js > /dev/null 2>&1 &
	@sleep 2
	@echo "Dashboard: http://localhost:8889"
	@echo ""
	@echo "Building all variants in parallel..."
	./scripts/build-demo-parallel.sh

# Cleanup
clean:
	@echo "🧹 Cleaning up demo environment..."
	./scripts/cleanup-demo.sh all
