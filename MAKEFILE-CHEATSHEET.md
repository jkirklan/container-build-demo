# Container Build Demo - Makefile Cheatsheet

Quick reference for all `make` commands in the three-track container demo.

## Quick Start

```bash
# Full pipeline: Build + Scan + Deploy + Test
make ubi              # UBI track (RHEL-based)
make rhhi             # RHHI track (distroless)
make bootc            # bootc track (image mode)
make all              # All three tracks

# Live demo with dashboard
make demo             # Start dashboard + build all in parallel
```

## Build Commands

Build container images with multi-architecture support (AMD64 + ARM64).

```bash
make build-ubi        # Build UBI images (webapp + db)
make build-rhhi       # Build RHHI images (webapp + db)
make build-bootc      # Build bootc image
make build-all        # Build all three variants sequentially
make build-parallel   # Build all in parallel (for live demos)
```

**When to use:**
- `build-ubi` / `build-rhhi` / `build-bootc` - Individual track development
- `build-all` - CI/CD pipelines (sequential, easier to debug)
- `build-parallel` - Live presentations (concurrent, faster)

## Security Scanning

Scan images for vulnerabilities and generate SBOMs.

```bash
make scan-ubi         # Trivy scan + SBOM for UBI images
make scan-rhhi        # Trivy scan + SBOM for RHHI images
make scan-bootc       # Trivy scan + SBOM for bootc image
```

**Output:**
- Vulnerability report (HIGH/CRITICAL CVEs)
- SBOM in `sboms/` directory (CycloneDX format)

**When to use:**
- After building images
- Before deployment
- Supply chain security audits

## Deployment

Deploy to local Podman (macOS or Linux).

```bash
make deploy-ubi       # Deploy UBI stack (db + webapp)
make deploy-rhhi      # Deploy RHHI stack (db + webapp)
```

**Behavior:**
- **macOS**: Uses `podman run` directly (no systemd)
- **Linux**: Uses systemd quadlets

**Ports:**
- UBI webapp: `http://localhost:3001`
- RHHI webapp: `http://localhost:3002`
- bootc: `http://localhost:3003` (when deployed locally)

## Testing

Run smoke tests against deployed stacks.

```bash
make test-ubi         # Test UBI stack (5 tests)
make test-rhhi        # Test RHHI stack (5 tests)
```

**Tests:**
1. ✅ Health check (`/health`)
2. ✅ List tasks (`GET /api/tasks`)
3. ✅ Create task (`POST /api/tasks`)
4. ✅ Update task (`PUT /api/tasks/:id`)
5. ✅ Delete task (`DELETE /api/tasks/:id`)

## Full Pipelines

Complete workflows from build to test.

```bash
make ubi              # Build → Scan → Deploy → Test (UBI)
make rhhi             # Build → Scan → Deploy → Test (RHHI)
make bootc            # Build → Scan (bootc, no local deploy)
make all              # All three pipelines
```

**Use case:** Full validation before pushing images to registry.

## Live Demo Dashboard

Start interactive dashboard for presentations.

```bash
make dashboard        # Start dashboard server on port 8888
make demo             # Dashboard + parallel builds
```

**Dashboard features:**
- Real-time build progress (SSE updates)
- Three-track comparison
- Vulnerability counts
- Image sizes

**Access:** `http://localhost:8888`

## Cleanup

Remove demo containers and data.

```bash
make clean            # Stop containers, remove data
```

**Warning:** Deletes all demo containers and persistent data!

## Port Reference

| Service | Port | Description |
|---------|------|-------------|
| UBI webapp | 3001 | Task tracker (UBI) |
| UBI database | 5432 | PostgreSQL (UBI) |
| RHHI webapp | 3002 | Task tracker (RHHI) |
| RHHI database | 5433 | PostgreSQL (RHHI) |
| bootc webapp | 3003 | Task tracker (bootc, reserved) |
| Dashboard | 8888 | Live demo dashboard |

**Note:** Port 3000 is intentionally avoided (conflicts with common dev tools).

## Image Naming

All images are pushed to GitHub Container Registry:

```
ghcr.io/jkirklan/demo-webapp-ubi:latest
ghcr.io/jkirklan/demo-db-ubi:latest
ghcr.io/jkirklan/demo-webapp-rhhi:latest
ghcr.io/jkirklan/demo-db-rhhi:latest
ghcr.io/jkirklan/demo-bootc:latest
```

## Common Workflows

### Development Iteration

```bash
# Edit code
vim webapp/src/app.js

# Rebuild and test
make build-ubi
make deploy-ubi
make test-ubi
```

### Pre-Presentation Check

```bash
# Verify everything works
make all

# Start dashboard for live demo
make demo
```

### Security Audit

```bash
# Scan all images
make scan-ubi
make scan-rhhi
make scan-bootc

# Review SBOMs
ls -lh sboms/
```

### Clean Start

```bash
# Remove everything
make clean

# Full rebuild
make all
```

## Troubleshooting

### Tests Failing

```bash
# Check container logs
podman logs demo-webapp-ubi
podman logs demo-db-ubi

# Check containers running
podman ps

# Manual health check
curl http://localhost:3001/health
```

### Build Failures

```bash
# Check Trivy is installed
trivy --version

# Check disk space
df -h

# Rebuild with verbose output
cd scripts && ./build-demo-ubi.sh
```

### Port Conflicts

```bash
# Check what's using ports
lsof -i :3001
lsof -i :3002

# Stop conflicting containers
podman stop $(podman ps -q)
```

## Help

```bash
make help             # Show all available targets
```

## Files Generated

```
sboms/                          # Software Bill of Materials
├── demo-db-ubi-YYYYMMDD.json
├── demo-webapp-ubi-YYYYMMDD.json
├── demo-db-rhhi-YYYYMMDD.json
└── demo-webapp-rhhi-YYYYMMDD.json

$HOME/demo-data/               # Persistent data (macOS)
├── ubi/postgres/
└── rhhi/postgres/

/etc/containers/systemd/       # Quadlets (Linux only)
├── demo-network.network
├── demo-db-ubi.container
├── demo-webapp-ubi.container
├── demo-db-rhhi.container
└── demo-webapp-rhhi.container
```

## Cross-Platform Notes

**macOS:**
- Uses rootless Podman
- Direct `podman run` (no systemd)
- Data in `$HOME/demo-data`

**Linux/RHEL:**
- Uses system Podman with sudo
- Systemd quadlets for service management
- Data in `/home/<user>/demo-data`

Both platforms use the same Makefile - OS detection is automatic!
