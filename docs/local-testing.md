# Local Testing Guide

Testing the demo environment locally on Mac (or any system without systemd).

## Quick Start

```bash
cd demo

# UBI stack
make build-ubi scan-ubi
# Then run containers manually (see below)

# RHHI stack
make build-rhhi scan-rhhi
# Then run containers manually (see below)
```

## Testing UBI Stack Locally

### 1. Start Containers

```bash
# Create secret (one time)
echo -n "demopassword123" | podman secret create demo-postgres-password -

# Create network
podman network create demo-net

# Start database (Red Hat PostgreSQL 15)
podman run -d \
  --name demo-db-ubi \
  --network demo-net \
  -p 5432:5432 \
  -e POSTGRESQL_DATABASE=taskdb \
  -e POSTGRESQL_USER=taskuser \
  --secret demo-postgres-password,type=env,target=POSTGRESQL_PASSWORD \
  ghcr.io/jkirklan/demo-db-ubi:latest

# Wait for database initialization
sleep 15

# Start webapp
podman run -d \
  --name demo-webapp-ubi \
  --network demo-net \
  -p 3000:3000 \
  -e POSTGRES_HOST=demo-db-ubi \
  -e POSTGRES_PORT=5432 \
  -e POSTGRES_DB=taskdb \
  -e POSTGRES_USER=taskuser \
  --secret demo-postgres-password,type=env,target=POSTGRES_PASSWORD \
  ghcr.io/jkirklan/demo-webapp-ubi:latest

# Wait for app startup
sleep 5
```

### 2. Initialize Database

The Red Hat PostgreSQL image doesn't automatically run init scripts. Initialize manually:

```bash
podman exec -i demo-db-ubi psql -U taskuser -d taskdb << 'SQL'
CREATE TABLE IF NOT EXISTS tasks (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  completed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_tasks_completed ON tasks(completed);
CREATE INDEX IF NOT EXISTS idx_tasks_created_at ON tasks(created_at DESC);

INSERT INTO tasks (title, description, completed) VALUES
  ('Build UBI container images', 'Build webapp and database containers using RHEL UBI base images', true),
  ('Build RHHI container images', 'Build webapp and database containers using Hummingbird base images', true),
  ('Run Trivy security scans', 'Scan both UBI and RHHI images for vulnerabilities', true),
  ('Generate SBOMs', 'Create CycloneDX Software Bill of Materials for supply chain transparency', true),
  ('Deploy demo locally', 'Test deployment on Mac with Podman', true);

SELECT * FROM tasks;
SQL
```

### 3. Test

```bash
# Health check
curl http://localhost:3000/health

# List tasks
curl http://localhost:3000/api/tasks | jq

# Create task
curl -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"Test Demo","description":"Testing UBI stack locally"}' | jq

# Web UI
open http://localhost:3000
```

### 4. Stop

```bash
podman stop demo-webapp-ubi demo-db-ubi
podman rm demo-webapp-ubi demo-db-ubi
```

## Testing RHHI Stack Locally

### 1. Start Containers

```bash
# Network and secret already exist from UBI test

# Start database (Hummingbird PostgreSQL 17)
# NOTE: Uses POSTGRES_* not POSTGRESQL_* environment variables
podman run -d \
  --name demo-db-rhhi \
  --network demo-net \
  -p 5432:5432 \
  -e POSTGRES_DB=taskdb \
  -e POSTGRES_USER=taskuser \
  --secret demo-postgres-password,type=env,target=POSTGRES_PASSWORD \
  ghcr.io/jkirklan/demo-db-rhhi:latest

# Wait for database initialization
sleep 15

# Start webapp (Hummingbird Node.js 20 distroless)
podman run -d \
  --name demo-webapp-rhhi \
  --network demo-net \
  -p 3000:3000 \
  -e POSTGRES_HOST=demo-db-rhhi \
  -e POSTGRES_PORT=5432 \
  -e POSTGRES_DB=taskdb \
  -e POSTGRES_USER=taskuser \
  --secret demo-postgres-password,type=env,target=POSTGRES_PASSWORD \
  ghcr.io/jkirklan/demo-webapp-rhhi:latest

# Wait for app startup
sleep 5
```

### 2. Initialize Database

```bash
podman exec -i demo-db-rhhi psql -U taskuser -d taskdb << 'SQL'
CREATE TABLE IF NOT EXISTS tasks (
  id SERIAL PRIMARY KEY,
  title VARCHAR(255) NOT NULL,
  description TEXT,
  completed BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_tasks_completed ON tasks(completed);
CREATE INDEX IF NOT EXISTS idx_tasks_created_at ON tasks(created_at DESC);

INSERT INTO tasks (title, description, completed) VALUES
  ('Build RHHI images', 'Built with Hummingbird distroless base images (PostgreSQL 17, Node.js 20)', true),
  ('Compare image sizes', 'RHHI: 285 MB vs UBI: 673 MB (58% smaller!)', true),
  ('Security scanning', 'Trivy scans show minimal CVEs in distroless images', true),
  ('Test RHHI locally', 'Deployed and tested on Mac ARM64', true);

SELECT * FROM tasks;
SQL
```

### 3. Test

Same commands as UBI testing (webapp runs on same port 3000).

### 4. Stop

```bash
podman stop demo-webapp-rhhi demo-db-rhhi
podman rm demo-webapp-rhhi demo-db-rhhi
```

## Key Differences: UBI vs RHHI

### Environment Variables

**UBI (Red Hat PostgreSQL 15):**
- `POSTGRESQL_DATABASE` (not POSTGRES_DATABASE)
- `POSTGRESQL_USER` (not POSTGRES_USER)
- `POSTGRESQL_PASSWORD` (not POSTGRES_PASSWORD)

**RHHI (Hummingbird PostgreSQL 17):**
- `POSTGRES_DB` (standard PostgreSQL naming)
- `POSTGRES_USER` (standard PostgreSQL naming)
- `POSTGRES_PASSWORD` (standard PostgreSQL naming)

### Image Sizes (ARM64)

| Stack | Webapp | Database | Total |
|-------|--------|----------|-------|
| UBI   | 245 MB | 428 MB   | 673 MB |
| RHHI  | 128 MB | 157 MB   | 285 MB |

**RHHI is 58% smaller!**

### PostgreSQL Versions

- **UBI**: PostgreSQL 15 (Red Hat official image)
- **RHHI**: PostgreSQL 17 (Hummingbird distroless)

## Multi-Architecture Notes

**No separate procedures needed for different architectures!**

The multi-arch manifest automatically selects the correct variant:
- **Mac (ARM64)**: Pulls `linux/arm64` variant
- **RHEL (AMD64)**: Pulls `linux/amd64` variant

Same commands work on both platforms. The manifest list handles platform detection.

## Test Results (2026-06-17)

### UBI Stack
- ✅ Health check: Database connected
- ✅ GET /api/tasks: Listed all tasks
- ✅ POST /api/tasks: Created new task
- ✅ PUT /api/tasks/:id: Updated task
- ✅ Web UI: Rendered correctly

### RHHI Stack
- ✅ Health check: Database connected
- ✅ GET /api/tasks: Listed all tasks
- ✅ POST /api/tasks: Created new task
- ✅ PUT /api/tasks/:id: Updated task
- ✅ Web UI: Rendered correctly

### Security Validation
- ✅ No secrets detected (gitleaks + Trivy)
- ✅ npm audit: 0 CVEs in dependencies
- ✅ Multi-arch manifests: Working correctly
- ✅ SBOMs generated: CycloneDX format

## Troubleshooting

### Database Connection Fails

**Symptom:** `ENOTFOUND demo-db-ubi` or `ENOTFOUND demo-db-rhhi`

**Cause:** Containers not on same network

**Fix:**
```bash
# Verify network exists
podman network inspect demo-net

# Recreate containers with --network demo-net
```

### Table Does Not Exist

**Symptom:** `error: relation "tasks" does not exist`

**Cause:** Database not initialized (init scripts don't auto-run in Red Hat/Hummingbird images)

**Fix:** Run the manual initialization SQL (see sections above)

### Wrong Environment Variables

**Symptom:** Database fails to start with password error

**Cause:** Using POSTGRESQL_* vars with Hummingbird or POSTGRES_* vars with Red Hat

**Fix:** Check "Environment Variables" section above for correct naming

## Production Deployment

For production deployment to kvm151 with systemd quadlets, see:
- `scripts/deploy-demo-ubi.sh`
- `scripts/deploy-demo-rhhi.sh`

Those scripts use systemd quadlets which aren't available on Mac.
