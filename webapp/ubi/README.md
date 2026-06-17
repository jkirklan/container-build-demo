# Task Tracker Web App - UBI Build

## Overview

This Containerfile builds the demo task tracker web application using **RHEL Universal Base Images (UBI)**, following the homelab's established security patterns.

## Base Images

- **Builder**: `registry.access.redhat.com/ubi9/nodejs-20:latest`
  - Full Node.js 20 runtime with dnf package manager
  - Used for npm install and build steps
  - ~200MB compressed

- **Runtime**: `registry.access.redhat.com/ubi9/nodejs-20-minimal:latest`
  - Minimal Node.js 20 runtime with microdnf
  - Production image without build tools
  - ~150MB compressed

## Security Features

### Build-Time Security
- ✅ **npm audit** - Scans for HIGH/CRITICAL vulnerabilities before install
- ✅ **Multi-stage build** - Build tools stay in builder, not in production image
- ✅ **npm ci** - Uses package-lock.json for reproducible builds

### Runtime Security
- ✅ **Non-root execution** - Runs as UID 1000 (webapp user)
- ✅ **Minimal base** - Only essential packages in production
- ✅ **Health checks** - Automatic service monitoring
- ✅ **OCI labels** - Metadata for image management

## Build Instructions

### Local Build (Mac/Development)
```bash
# From demo/webapp/ubi directory
cd /Users/jkirklan/git/homelab/demo/webapp/ubi

# Build for local architecture (ARM64 on Mac)
podman build -t ghcr.io/jkirklan/demo-webapp-ubi:latest .

# Test locally
podman run --rm -p 3000:3000 \
  -e POSTGRES_HOST=host.docker.internal \
  -e POSTGRES_DB=taskdb \
  -e POSTGRES_USER=taskuser \
  -e POSTGRES_PASSWORD=demopassword \
  ghcr.io/jkirklan/demo-webapp-ubi:latest
```

### Multi-Architecture Build (Production)
```bash
# Use homelab's build-multiarch.sh script
cd /Users/jkirklan/git/homelab/demo/webapp/ubi
../../../containerfiles/build-multiarch.sh . ghcr.io/jkirklan/demo-webapp-ubi:latest

# This builds for both:
# - linux/amd64 (kvm151 production)
# - linux/arm64 (Mac development)
```

### Security Scanning
```bash
# Scan with Trivy
$HOME/.local/bin/trivy image --severity HIGH,CRITICAL ghcr.io/jkirklan/demo-webapp-ubi:latest

# Generate SBOM
$HOME/.local/bin/trivy image --format cyclonedx --output sbom.json ghcr.io/jkirklan/demo-webapp-ubi:latest
```

## Deployment

### Environment Variables
- `POSTGRES_HOST` - Database hostname (default: localhost)
- `POSTGRES_PORT` - Database port (default: 5432)
- `POSTGRES_DB` - Database name
- `POSTGRES_USER` - Database user
- `POSTGRES_PASSWORD` - Database password (via Podman secret)
- `PORT` - Web server port (default: 3000)

### Podman Quadlet
See `demo/quadlets/demo-webapp-ubi.container` for systemd integration.

## UBI Approach Benefits

### ✅ Enterprise Support
- 10-year lifecycle (RHEL 9 until ~2032)
- Security patches from Red Hat
- FIPS 140-2 compliance option

### ✅ Package Manager Available
- `microdnf` available in runtime image
- Can install additional packages if needed
- Familiar tooling for RHEL administrators

### ✅ Proven Track Record
- Battle-tested in production environments
- Extensive CVE scanning and remediation
- Used by Fortune 500 companies

## UBI Approach Trade-offs

### ⚠️ Larger Image Size
- Runtime image ~150MB (vs ~40MB for RHHI distroless)
- More packages = larger attack surface
- Slower image pulls

### ⚠️ More CVEs
- Package manager in runtime adds vulnerabilities
- Dev tools dependencies increase CVE count
- Requires ongoing vulnerability management

## Comparison: UBI vs RHHI

| Metric | UBI (This Build) | RHHI (Alternative) |
|--------|------------------|--------------------|
| **Base OS** | RHEL 9 | Fedora (Hummingbird) |
| **Runtime Size** | ~150MB | ~40MB |
| **Package Manager** | microdnf | None (distroless) |
| **Support** | Enterprise (Red Hat) | Community |
| **Lifecycle** | 10 years | Rolling (Fedora) |
| **CVE Count** | Moderate (50-100) | Minimal (5-15) |
| **Best For** | Production, regulated | Microservices, edge |

## Lessons Learned

### ✅ What Works Well
- Multi-stage builds eliminate 90% of CVEs from build tools
- npm audit catches supply chain attacks early
- Health checks integrate seamlessly with Podman

### ⚠️ Gotchas
- **Always use `microdnf`**, not `dnf` (dnf not available in minimal images)
- **Disable all repos** then enable only `ubi-9-*` to avoid subscription errors
- **Use full binary paths** (`/usr/bin/node`) not symlinks in minimal images

## Related Files
- **Containerfile**: This directory
- **Source code**: `demo/webapp/src/`
- **RHHI alternative**: `demo/webapp/rhhi/Containerfile`
- **Database**: `demo/database/ubi/Containerfile`
- **Deployment**: `demo/quadlets/demo-webapp-ubi.container`
