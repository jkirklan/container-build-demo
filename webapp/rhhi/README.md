# Task Tracker Web App - RHHI (Hummingbird) Build

## Overview

This Containerfile builds the demo task tracker web application using **Red Hat Hummingbird Images**, the ultra-minimal distroless alternative to UBI.

## Hummingbird Image Details

**Discovered via API:** 2026-06-16

### Builder Image
- **Pull URL**: `registry.access.redhat.com/hi/nodejs:20-builder`
- **Version**: 20.20.2
- **Size**: 85.5 MB (AMD64), 82.8 MB (ARM64)
- **Variant**: `builder`
- **Tools**: bash, dnf, shadow-utils

### Runtime Image
- **Pull URL**: `registry.access.redhat.com/hi/nodejs:20`
- **Version**: 20.20.2
- **Size**: **44.8 MB (AMD64)**, **42.8 MB (ARM64)** ← 70% smaller than UBI!
- **Variant**: `default` (distroless)
- **CVE Count**: **17 total (11 HIGH, 4 MEDIUM, 2 LOW, 0 CRITICAL)**

## Key Differences from UBI

### ✅ Distroless Runtime
- **NO package manager** (no microdnf, no dnf)
- **NO shell** (no bash, no sh)
- **NO shadow-utils** (no useradd, no groupadd)
- **Minimal attack surface** - only runtime dependencies

### ✅ Ultra-Small Size
- 44.8 MB vs 150 MB (UBI) = **70% reduction**
- Faster image pulls
- Less disk space
- Faster container startup

### ✅ Fedora-Based
- Rolling release (newer packages)
- Faster security updates
- Bleeding-edge Node.js features

### ⚠️ Trade-offs
- **No runtime package manager** - can't `microdnf install` at runtime
- **No shell access** - can't `podman exec -it container bash`
- **Less enterprise support** - community-driven, not Red Hat supported
- **No FIPS mode** for this demo (FIPS variants available separately)

## Build Instructions

### Multi-Stage Pattern
```dockerfile
# Stage 1: Builder (Fedora with tools)
FROM registry.access.redhat.com/hi/nodejs:20-builder AS builder
RUN npm ci

# Stage 2: Runtime (distroless)
FROM registry.access.redhat.com/hi/nodejs:20
COPY --from=builder /build /app
```

### Local Build
```bash
cd /Users/jkirklan/git/homelab/demo/webapp/rhhi
podman build -t ghcr.io/jkirklan/demo-webapp-rhhi:latest .
```

### Multi-Architecture Build
```bash
cd /Users/jkirklan/git/homelab/demo/webapp/rhhi
../../../containerfiles/build-multiarch.sh . ghcr.io/jkirklan/demo-webapp-rhhi:latest
```

## Security Features

### Build-Time Security
- ✅ **npm audit** - Same HIGH/CRITICAL failure threshold as UBI
- ✅ **Multi-stage build** - Build tools never reach production
- ✅ **npm ci** - Reproducible builds via package-lock.json

### Runtime Security
- ✅ **Distroless** - No package manager = smaller attack surface
- ✅ **Non-root** - Runs as UID 65532 (default Hummingbird user)
- ✅ **Health checks** - `wget --spider` (not curl!)
- ✅ **Minimal CVEs** - 17 total (11 HIGH) vs ~100+ in UBI

### CRITICAL Gotcha: wget vs curl
```dockerfile
# ❌ WRONG - curl not included in distroless
HEALTHCHECK CMD curl -f http://localhost:3000/health

# ✅ CORRECT - wget is included
HEALTHCHECK CMD wget --spider -q http://localhost:3000/health
```

## Deployment

### Environment Variables
- `POSTGRES_HOST` - Database hostname
- `POSTGRES_PORT` - Database port (default: 5432)
- `POSTGRES_DB` - Database name
- `POSTGRES_USER` - Database user
- `POSTGRES_PASSWORD` - Database password (via Podman secret)

### Podman Quadlet
See `demo/quadlets/demo-webapp-rhhi.container`

## Comparison: RHHI vs UBI

| Metric | RHHI (This Build) | UBI (Alternative) |
|--------|-------------------|-------------------|
| **Base OS** | Fedora (Hummingbird) | RHEL 9 |
| **Runtime Size** | **44.8 MB** | 150 MB |
| **Package Manager** | **None (distroless)** | microdnf |
| **Shell Access** | **No** | Yes (bash) |
| **Support** | Community | Enterprise (Red Hat) |
| **Lifecycle** | Rolling (Fedora) | 10 years (RHEL) |
| **CVE Count** | **17 (11 HIGH)** | ~100+ |
| **Best For** | **Microservices, edge, demo** | Production, regulated |

## Debugging Distroless Containers

### No Shell Access
```bash
# ❌ This won't work (no bash)
podman exec -it demo-webapp-rhhi bash

# ✅ Use debugging sidecar instead
podman run --rm -it --network container:demo-webapp-rhhi \
  registry.access.redhat.com/ubi9/ubi-minimal bash

# Inside sidecar container:
curl http://localhost:3000/health
```

### View Logs Only
```bash
# Without shell, logs are your only visibility
podman logs demo-webapp-rhhi -f
```

## Why Choose RHHI for This Demo?

### ✅ Perfect for Demo Showcase
- **Dramatic size difference** (44 MB vs 150 MB) - great for slides
- **Impressive CVE reduction** (17 vs 100+) - shows security benefit
- **Modern approach** - demonstrates distroless best practices

### ✅ Production-Ready for This Use Case
- Simple Node.js app (no complex dependencies)
- No runtime package installation needed
- Health checks work with wget
- Stateless web tier (database handles persistence)

### ⚠️ Not Always the Right Choice
- **Complex apps** - use UBI if you need runtime package manager
- **Legacy systems** - use UBI for 10-year support
- **Regulated industries** - use UBI for RHEL compliance
- **Debugging needs** - use UBI if shell access is critical

## Hummingbird API Reference

Images discovered via REST API:
```bash
# List Node.js images
curl -s --compressed https://api-hummingbird.hummingbird-project.io/v1/images/nodejs/tags

# Get CVE summary
curl -s --compressed https://api-hummingbird.hummingbird-project.io/v1/images/nodejs/vulnerabilities/20.20.2

# Get SBOM
curl -s --compressed https://api-hummingbird.hummingbird-project.io/v1/images/nodejs/sbom/20.20.2
```

## Related Files
- **Containerfile**: This directory
- **Source code**: `demo/webapp/src/`
- **UBI alternative**: `demo/webapp/ubi/Containerfile`
- **Database**: `demo/database/rhhi/Containerfile`
- **Deployment**: `demo/quadlets/demo-webapp-rhhi.container`
