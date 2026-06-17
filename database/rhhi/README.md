# PostgreSQL Database - RHHI (Hummingbird) Build

## Overview

This Containerfile builds PostgreSQL 17 using **Red Hat Hummingbird Images**, achieving **ZERO CVEs** with distroless architecture.

## Hummingbird Image Details

**Discovered via API:** 2026-06-16

### Builder Image
- **Pull URL**: `registry.access.redhat.com/hi/postgresql:17-builder`
- **Version**: 17.10
- **Size**: 85.8 MB (AMD64), 83.4 MB (ARM64)
- **Variant**: `builder`
- **Tools**: bash, dnf, shadow-utils

### Runtime Image
- **Pull URL**: `registry.access.redhat.com/hi/postgresql:17`
- **Version**: 17.10
- **Size**: **56.8 MB (AMD64)**, **55.1 MB (ARM64)** ← 53% smaller than UBI!
- **Variant**: `default` (distroless)
- **CVE Count**: **0 TOTAL** ← **ZERO vulnerabilities!**

## Why PostgreSQL 17 (not 15)?

Hummingbird currently provides PostgreSQL 17 and 18 streams. PostgreSQL 15 is not available. Using PostgreSQL 17 for this demo provides:
- **Zero CVEs** (vs ~10-20 in PostgreSQL 15 on UBI)
- **Newer features** (JSON improvements, performance gains)
- **Active support** (PostgreSQL 17 released Sept 2024)

The demo application is compatible with any PostgreSQL version 12+.

## Security Achievement: ZERO CVEs

```bash
# Actual scan results from Hummingbird API
curl -s --compressed "https://api-hummingbird.hummingbird-project.io/v1/images/postgresql/vulnerabilities/17.10" | jq '.summary'

{
  "total": 0,
  "critical": 0,
  "high": 0,
  "medium": 0,
  "low": 0
}
```

**This is the power of distroless:** No package manager = no package manager CVEs!

## Key Differences from UBI

### ✅ Distroless Runtime
- **NO package manager** (no microdnf)
- **NO shell** (no bash - can't run startup scripts!)
- **NO runtime configuration** - everything pre-baked in builder

### ✅ ZERO CVEs
- Distroless eliminates 100% of package manager vulnerabilities
- Minimal runtime = minimal attack surface
- **Perfect security score**

### ✅ Smaller Size
- 56.8 MB vs 120 MB (UBI) = **53% reduction**
- Faster deployment
- Less disk/network usage

### ⚠️ Trade-offs
- **No shell scripts** - can't use traditional docker-entrypoint.sh pattern
- **No runtime init** - database must be initialized in builder stage
- **No debugging** - can't `podman exec -it bash` to troubleshoot

## Build Instructions

### Multi-Stage Pattern
```dockerfile
# Stage 1: Builder (initialize database)
FROM registry.access.redhat.com/hi/postgresql:17-builder AS builder
RUN postgresql-setup --initdb
RUN configure pg_hba.conf, postgresql.conf

# Stage 2: Runtime (distroless)
FROM registry.access.redhat.com/hi/postgresql:17
COPY --from=builder /var/lib/pgsql /var/lib/pgsql
CMD ["/usr/bin/postgres", "-D", "/var/lib/pgsql/data"]
```

**CRITICAL:** Because there's no shell in the runtime image, you CANNOT use:
```dockerfile
# ❌ WRONG - no /bin/bash in distroless
CMD /bin/bash -c 'if [ ! -f /data/PG_VERSION ]; then init; fi; postgres'

# ✅ CORRECT - direct binary execution
CMD ["/usr/bin/postgres", "-D", "/var/lib/pgsql/data"]
```

### Local Build
```bash
cd /Users/jkirklan/git/homelab/demo/database/rhhi
podman build -t ghcr.io/jkirklan/demo-db-rhhi:latest .
```

### Multi-Architecture Build
```bash
cd /Users/jkirklan/git/homelab/demo/database/rhhi
../../../containerfiles/build-multiarch.sh . ghcr.io/jkirklan/demo-db-rhhi:latest
```

## Database Initialization

Because distroless has no shell, initialization happens in the **builder stage**:

1. `postgresql-setup --initdb` in builder
2. Configure `pg_hba.conf` for network access
3. Configure `postgresql.conf` for listen_addresses
4. Copy entire `/var/lib/pgsql` to runtime image
5. Runtime image starts PostgreSQL directly (no init script)

### Schema (from init.sql)
Schema is applied at runtime via volume mount or manual `psql` execution (not in Containerfile due to user/password requirement).

## Deployment

### Environment Variables
- `POSTGRES_DB` - Database name (default: taskdb)
- `POSTGRES_USER` - Database user (default: taskuser)
- `POSTGRES_PASSWORD` - User password (via Podman secret)

**Note:** User/database creation must happen at runtime (can't create users without password in builder).

### Podman Quadlet
See `demo/quadlets/demo-db-rhhi.container`

### Data Persistence
```ini
Volume=/home/jkirklan/demo-data/rhhi/postgres:/var/lib/pgsql/data:Z
```

## Testing

### Health Check
```bash
podman exec demo-db-rhhi pg_isready -U postgres
# Expected: /var/run/postgresql:5432 - accepting connections
```

### Connection Test
```bash
# From host (if port published)
psql -h localhost -p 5433 -U taskuser -d taskdb
```

## Comparison: RHHI vs UBI

| Metric | RHHI (This Build) | UBI (Alternative) |
|--------|-------------------|-------------------|
| **PostgreSQL Version** | 17.10 | 15.x |
| **Base OS** | Fedora (Hummingbird) | RHEL 9 |
| **Runtime Size** | **56.8 MB** | 120 MB |
| **Package Manager** | **None (distroless)** | microdnf |
| **Shell Access** | **No** | Yes |
| **CVE Count** | **0 (ZERO!)** | ~10-20 |
| **Init Scripts** | **No** | Yes |
| **Best For** | **Security-first, demo** | Production, ops tooling |

## Debugging Distroless Database

### No Shell Access
```bash
# ❌ Won't work (no bash)
podman exec -it demo-db-rhhi bash

# ✅ Use psql directly
podman exec -it demo-db-rhhi psql -U postgres

# ✅ Or debugging sidecar
podman run --rm -it --network container:demo-db-rhhi \
  registry.access.redhat.com/ubi9/ubi-minimal bash

# Inside sidecar:
psql -h localhost -U taskuser taskdb
```

### View Logs
```bash
podman logs demo-db-rhhi -f
```

### Database State
```bash
# Check running queries
podman exec demo-db-rhhi psql -U postgres -c "SELECT * FROM pg_stat_activity;"

# Check database size
podman exec demo-db-rhhi psql -U postgres -c "SELECT pg_database_size('taskdb');"
```

## Why Choose RHHI for Database?

### ✅ Perfect for Security Demo
- **ZERO CVEs** - unbeatable security story
- **Smallest possible footprint** - 56 MB total
- **Modern PostgreSQL** - version 17 features

### ✅ Production-Ready for Stateless Apps
- No runtime configuration needed
- Health checks work (pg_isready included)
- psql client available for debugging

### ⚠️ Consider UBI Instead If:
- **Need shell access** - for operational troubleshooting
- **Complex init scripts** - database migrations, extensions
- **PostgreSQL 15 required** - version-specific compatibility
- **Enterprise support** - Red Hat backing needed

## Hummingbird API Reference

Images discovered via REST API:
```bash
# List PostgreSQL images
curl -s --compressed https://api-hummingbird.hummingbird-project.io/v1/images/postgresql/tags

# Get CVE summary (shows ZERO!)
curl -s --compressed https://api-hummingbird.hummingbird-project.io/v1/images/postgresql/vulnerabilities/17.10

# Get SBOM
curl -s --compressed https://api-hummingbird.hummingbird-project.io/v1/images/postgresql/sbom/17.10
```

## Related Files
- **Containerfile**: This directory
- **Schema**: `demo/database/init.sql`
- **UBI alternative**: `demo/database/ubi/Containerfile`
- **Web app**: `demo/webapp/rhhi/Containerfile`
- **Deployment**: `demo/quadlets/demo-db-rhhi.container`
