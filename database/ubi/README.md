# PostgreSQL Database - UBI Build

## Overview

This Containerfile builds PostgreSQL 15 using **RHEL UBI Minimal**, following homelab security patterns for database containers.

## Base Image

- **Image**: `registry.access.redhat.com/ubi9/ubi-minimal:latest`
- **Size**: ~40MB base + PostgreSQL packages
- **Total**: ~120MB compressed

## Security Features

### Build-Time Security
- ✅ **Minimal base image** - Only essential packages
- ✅ **Official PostgreSQL packages** - From Red Hat UBI repos
- ✅ **No build tools** - Direct package install, no compilation

### Runtime Security
- ✅ **Non-root execution** - Runs as UID 999 (postgres user)
- ✅ **Restricted shell** - /bin/bash for postgres user only
- ✅ **Health checks** - pg_isready monitoring
- ✅ **Volume isolation** - Data directory in separate volume

## Build Instructions

### Local Build
```bash
cd /Users/jkirklan/git/homelab/demo/database/ubi
podman build -t ghcr.io/jkirklan/demo-db-ubi:latest .
```

### Multi-Architecture Build
```bash
cd /Users/jkirklan/git/homelab/demo/database/ubi
../../../containerfiles/build-multiarch.sh . ghcr.io/jkirklan/demo-db-ubi:latest
```

## Database Initialization

The container automatically initializes the database on first run:

1. Runs `postgresql-setup --initdb`
2. Configures pg_hba.conf for network access
3. Creates user from `POSTGRES_USER` env var
4. Creates database from `POSTGRES_DB` env var
5. Executes `/docker-entrypoint-initdb.d/init.sql`

### Schema (from init.sql)
```sql
CREATE TABLE tasks (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  completed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

## Deployment

### Environment Variables
- `POSTGRES_DB` - Database name (default: taskdb)
- `POSTGRES_USER` - Database user (default: taskuser)
- `POSTGRES_PASSWORD` - User password (via Podman secret)

### Podman Quadlet
See `demo/quadlets/demo-db-ubi.container` for systemd integration.

### Data Persistence
Database files stored in volume:
```ini
Volume=/home/jkirklan/demo-data/ubi/postgres:/var/lib/pgsql/data:Z
```

## Testing

### Test Database Connection
```bash
# From container
podman exec demo-db-ubi psql -U taskuser -d taskdb -c "SELECT version();"

# From host (if port published)
psql -h localhost -p 5432 -U taskuser -d taskdb
```

### Health Check
```bash
podman exec demo-db-ubi pg_isready -U postgres
# Expected: /var/run/postgresql:5432 - accepting connections
```

## UBI Database Benefits

### ✅ Enterprise Support
- RHEL-supported PostgreSQL packages
- Security patches from Red Hat
- Long-term stability (10-year lifecycle)

### ✅ Familiar Tooling
- Standard PostgreSQL commands
- Compatible with pgAdmin, DBeaver, etc.
- Same pg_dump/pg_restore as upstream

### ✅ Production-Ready
- Used in enterprise environments
- Well-documented troubleshooting
- Strong RHEL community

## Trade-offs

### ⚠️ Package Dependencies
- More packages than distroless approach
- Larger attack surface
- More CVEs to manage

### ⚠️ Image Size
- ~120MB (vs ~60MB for RHHI distroless)
- Slower image pulls
- More disk space

## Troubleshooting

### Database Won't Start
```bash
# Check logs
podman logs demo-db-ubi

# Check data directory permissions
podman exec demo-db-ubi ls -la /var/lib/pgsql/data

# Re-initialize (WARNING: deletes all data)
podman volume rm demo-db-ubi-data
podman restart demo-db-ubi
```

### Connection Refused
```bash
# Verify PostgreSQL is listening
podman exec demo-db-ubi netstat -tlnp | grep 5432

# Check pg_hba.conf
podman exec demo-db-ubi cat /var/lib/pgsql/data/pg_hba.conf
```

## Related Files
- **Containerfile**: This directory
- **Schema**: `demo/database/init.sql`
- **RHHI alternative**: `demo/database/rhhi/Containerfile`
- **Web app**: `demo/webapp/ubi/Containerfile`
- **Deployment**: `demo/quadlets/demo-db-ubi.container`
