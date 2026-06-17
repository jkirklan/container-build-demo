# Container Build Pipeline Demo: UBI vs RHHI vs Bootc

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Podman](https://img.shields.io/badge/Podman-892CA0?logo=podman&logoColor=white)](https://podman.io/)
[![Node.js](https://img.shields.io/badge/Node.js-20-339933?logo=node.js&logoColor=white)](https://nodejs.org/)
[![PostgreSQL](https://img.shields.io/badge/PostgreSQL-15%20%7C%2017-4169E1?logo=postgresql&logoColor=white)](https://www.postgresql.org/)
[![Security: Trivy](https://img.shields.io/badge/Security-Trivy-1904DA?logo=aqua&logoColor=white)](https://trivy.dev/)
[![SBOM: CycloneDX](https://img.shields.io/badge/SBOM-CycloneDX-00ADD8)](https://cyclonedx.org/)

A comprehensive demonstration of security-first container build and deployment pipelines using three approaches:
- **UBI** (RHEL Universal Base Images) - Enterprise-grade, flexible, traditional containers
- **RHHI** (Red Hat Hummingbird Images) - Ultra-minimal distroless containers
- **Bootc** (Bootable Containers) - Immutable OS images with built-in application

## 📋 What's Inside

This demo showcases:
- ✅ **Multi-stage container builds** with npm audit security scanning
- ✅ **Trivy vulnerability scanning** + SBOM generation
- ✅ **Multi-architecture support** (AMD64 + ARM64)
- ✅ **Podman quadlet deployment** with systemd integration
- ✅ **Traefik reverse proxy** with TLS termination
- ✅ **FreeIPA DNS** integration
- ✅ **Secret management** with Podman secrets

## 🏗️ Architecture

### Application Stack
- **Frontend**: Node.js 20 + Express.js task tracker
- **Backend**: PostgreSQL database (15 for UBI, 17 for RHHI)
- **Deployment**: Podman containers with systemd quadlets
- **Networking**: Isolated Podman network (demo-net)
- **Routing**: Traefik HTTPS reverse proxy
- **DNS**: FreeIPA (lab.kubelet.org)

### Three Deployment Paradigms

| Component | UBI (Container) | RHHI (Distroless) | Bootc (OS Image) |
|-----------|----------------|-------------------|------------------|
| **Type** | Application container | Application container | Bootable OS image |
| **Base** | ubi9/nodejs-20-minimal | hi/nodejs:20 (distroless) | rhel9/rhel-bootc + Hummingbird |
| **Total Size** | 645 MB | **276 MB** (58% smaller) | ~1-2 GB (full OS) |
| **Package Manager** | microdnf ✅ | None (distroless) | dnf (build only) |
| **Shell Access** | bash ✅ | None (distroless) | SSH (post-boot) |
| **Runtime** | Podman | Podman | Systemd (native boot) |
| **Updates** | Pull + restart | Pull + restart | bootc upgrade + reboot |
| **Isolation** | Namespace/cgroup | Namespace/cgroup | Full system |
| **Support** | Red Hat Enterprise | Community (Hummingbird) | Red Hat Enterprise (RHEL) |
| **Lifecycle** | 10 years | Rolling (Fedora) | 10 years (RHEL) |
| **Use Case** | General apps | Security-first apps | Appliances, immutable infra |

## 📁 Directory Structure

```
demo/
├── README.md                      # This file
├── Makefile                       # Build automation (make ubi, make rhhi, make all)
├── backlog.md                     # Task tracking
├── docs/
│   ├── local-testing.md           # Local testing guide (Mac/non-systemd)
│   ├── test-results.md            # Comprehensive test results
│   ├── pipeline-comparison.md     # Local vs CI/CD pipeline comparison
│   └── npm-malware-detection.md   # npm malware detection guide
├── architecture/                  # Mermaid diagrams
│   ├── system-diagram.mmd
│   ├── build-pipeline.mmd
│   ├── deployment-flow.mmd
│   └── network-topology.mmd
├── slides/
│   └── demo-presentation.md       # Reveal.js presentation
├── webapp/
│   ├── src/                       # Shared source code
│   │   ├── app.js                 # Express server
│   │   ├── db.js                  # PostgreSQL connection
│   │   ├── routes/tasks.js        # CRUD API
│   │   └── public/                # Web UI
│   ├── ubi/                       # UBI build (traditional container)
│   │   ├── Containerfile
│   │   └── README.md
│   ├── rhhi/                      # RHHI build (distroless container)
│   │   ├── Containerfile
│   │   └── README.md
│   └── bootc/                     # Bootc build (bootable OS image)
│       ├── Containerfile
│       ├── README.md
│       └── build.sh
│       ├── Containerfile
│       └── README.md
├── database/
│   ├── init.sql                   # Shared schema
│   ├── ubi/
│   │   ├── Containerfile
│   │   └── README.md
│   └── rhhi/
│       ├── Containerfile
│       └── README.md
├── quadlets/                      # Podman systemd units
│   ├── demo-network.network
│   ├── demo-db-ubi.container
│   ├── demo-webapp-ubi.container
│   ├── demo-db-rhhi.container
│   └── demo-webapp-rhhi.container
├── scripts/                       # Deployment automation
│   ├── build-demo-ubi.sh
│   ├── build-demo-rhhi.sh
│   ├── scan-demo.sh
│   ├── deploy-demo-ubi.sh
│   ├── deploy-demo-rhhi.sh
│   ├── cleanup-demo.sh
│   └── demo-tests.sh
├── traefik/
│   └── demo-routes.yml            # Traefik configuration
└── sboms/                         # Generated SBOMs (not in git)
```

## 🚀 Quick Start

### Prerequisites
- Podman installed (rootless mode)
- systemd (for quadlets)
- Trivy installed (`brew install trivy` or see scripts)
- Access to homelab infrastructure (FreeIPA, Traefik)
- GNU Make (standard on all Unix systems)

### Simplified Build Automation

The demo includes a **Makefile** for easy automation:

```bash
cd demo

# See all available targets
make help

# Build only
make build-ubi          # Build UBI images
make build-rhhi         # Build RHHI images
make build-all          # Build both

# Full pipelines (build + scan + deploy + test)
make ubi                # Complete UBI pipeline
make rhhi               # Complete RHHI pipeline
make all                # Both stacks

# Cleanup
make clean              # Remove all demo resources
```

### Manual Script Execution (Alternative)

You can also run scripts directly for more control:

**1. Build Images:**
```bash
./scripts/build-demo-ubi.sh     # UBI stack
./scripts/build-demo-rhhi.sh    # RHHI stack
```

Both scripts:
- Build multi-architecture images (AMD64 + ARM64)
- Run npm audit security scanning
- Execute Trivy CVE scans
- Generate SBOMs in CycloneDX format

**2. Deploy:**
```bash
./scripts/deploy-demo-ubi.sh    # UBI demo
./scripts/deploy-demo-rhhi.sh   # RHHI demo
```

Deployment includes:
- Creating Podman secrets
- Creating data directories
- Installing quadlet files
- Starting services (database → webapp)

**3. Test:**
```bash
./scripts/demo-tests.sh ubi     # Test UBI stack
./scripts/demo-tests.sh rhhi    # Test RHHI stack
```

**Manual testing:**
```bash
# UBI stack (port 3000)
curl http://localhost:3000/health
curl http://localhost:3000/api/tasks

# RHHI stack (port 3001)
curl http://localhost:3001/health
curl http://localhost:3001/api/tasks
```

**4. Access Web UI:**

**Locally:**
- UBI: http://localhost:3000
- RHHI: http://localhost:3001

**Via Traefik (after DNS setup):**
- UBI: https://demo-ubi.lab.kubelet.org
- RHHI: https://demo-rhhi.lab.kubelet.org

### Recommended Workflow

For the **fastest iteration** during development:

```bash
# Quick rebuild and test
make build-ubi scan-ubi deploy-ubi test-ubi

# Or use the full pipeline target
make ubi
```

For **team demos** or **production releases**, push to GitHub to trigger CI/CD (see "Pipeline Execution" section below).

## 🔐 Security Features

### Build-Time Security

**npm audit:**
```dockerfile
RUN npm audit --production --audit-level=high || \
    (echo "ERROR: HIGH or CRITICAL vulnerabilities found" && exit 1)
```
- Scans for HIGH/CRITICAL npm vulnerabilities
- **Fails the build** if vulnerabilities found
- Prevents vulnerable dependencies from reaching production

**Enhanced npm malware detection (optional):**
```bash
# Before building
./scripts/npm-security-check.sh
```
- Detects typosquatting (loadsh → lodash, reacct → react)
- Finds packages with install scripts (malware risk)
- Validates lockfile integrity
- Checks registry trust
- See `docs/npm-malware-detection.md` for commercial tools (Socket.dev, Snyk)

**Multi-stage builds:**
- Builder stage: Full image with build tools
- Runtime stage: Minimal image without dev dependencies
- **Result**: 90% fewer CVEs from build tools

**Trivy secret scanning:**
```bash
trivy image --scanners secret ghcr.io/jkirklan/demo-webapp-ubi:latest
```
- Detects hardcoded secrets in images
- Finds: API keys, passwords, AWS credentials, private keys
- **Fails the build** if HIGH/CRITICAL secrets found
- Prevents credential leakage to registry

**Trivy CVE scanning:**
```bash
trivy image --severity HIGH,CRITICAL ghcr.io/jkirklan/demo-webapp-ubi:latest
```
- Post-build CVE scanning
- Severity filtering (HIGH, CRITICAL)
- Non-blocking (reports issues, doesn't fail build)

**SBOM generation:**
```bash
trivy image --format cyclonedx --output sbom.json ghcr.io/jkirklan/demo-webapp-ubi:latest
```
- CycloneDX format (industry standard)
- Supply chain transparency
- Incident response ready (grep for compromised packages)

### Runtime Security

**Non-root execution:**
- UBI: UID 1000 (webapp), UID 999 (postgres)
- RHHI: UID 65532 (distroless default)
- No root privileges needed

**Secret management:**
```bash
echo -n "password" | podman secret create demo-postgres-password -
```
- Podman native secrets (encrypted at rest)
- Never hardcoded in containers
- Mounted as environment variables

**Health checks:**
```ini
HealthCmd=curl -f http://localhost:3000/health || exit 1
HealthInterval=30s
```
- Automated service monitoring
- Container restart on failure
- Integration with Podman/systemd

**Network isolation:**
```ini
Network=demo-net
```
- Dedicated Podman network
- Isolated from host network
- Container-to-container DNS

## 📊 Build Pipeline

**Two execution models available:**
1. **Local Pipeline** - Manual scripts for development
2. **CI/CD Pipeline** - GitHub Actions for production

### Pipeline Stages (Both Models)

1. **Source Code** → Node.js + Express + PostgreSQL client
2. **Containerfile** → Multi-stage build with security scanning
3. **npm audit** → Scan for vulnerable dependencies (FAIL on HIGH/CRITICAL)
4. **Build** → Create multi-arch images (AMD64 + ARM64)
5. **Secret Scan** → Trivy secret detection (FAIL on HIGH/CRITICAL)
6. **CVE Scan** → Trivy vulnerability scanning
7. **SBOM** → Generate Software Bill of Materials
8. **Push** → Upload to ghcr.io registry
9. **Deploy** → Podman quadlets with systemd

### Security Gates

**Gate 1: npm audit (build-time)**
- Threshold: HIGH or CRITICAL
- Action: **FAIL BUILD**
- Prevents: Supply chain attacks

**Gate 2: Trivy secret scan (post-build)**
- Threshold: HIGH or CRITICAL secrets
- Action: **FAIL BUILD**
- Prevents: Hardcoded credentials in images
- Detects: API keys, passwords, tokens, private keys

**Gate 3: Trivy CVE scan (post-build)**
- Threshold: Report HIGH/CRITICAL
- Action: Report (non-blocking)
- Prevents: Shipping vulnerable images

**Gate 4: SBOM generation**
- Format: CycloneDX JSON
- Purpose: Supply chain transparency
- Use: Incident response

## 🎯 Use Cases

### When to Use UBI

✅ **Enterprise Production**
- Red Hat support required
- 10-year lifecycle needed
- FIPS compliance required

✅ **Operational Flexibility**
- Need runtime package installation
- Need shell access for debugging
- Complex runtime configuration

✅ **Regulated Industries**
- Banking, healthcare, government
- Compliance requirements
- Audit trail needed

### When to Use RHHI

✅ **Security-First Applications**
- Minimize attack surface
- Zero-CVE requirement
- Distroless architecture

✅ **Microservices**
- Many small containers
- Bandwidth-constrained
- Fast startup required

✅ **Edge Computing**
- Limited resources
- Smaller image sizes
- Modern stack

### This Demo: Why Both?

**Educational Value:**
- Shows two valid approaches
- Demonstrates trade-offs
- Highlights decision criteria

**Real-World Comparison:**
- Same application, different bases
- Apples-to-apples metrics
- Side-by-side deployment

## 🧪 Testing the Demo

### Automated Tests

```bash
./scripts/demo-tests.sh ubi
```

Tests run:
1. Health check endpoint
2. List tasks (GET /api/tasks)
3. Create task (POST /api/tasks)
4. Update task (PUT /api/tasks/:id)
5. Delete task (DELETE /api/tasks/:id)

### Manual Testing

**Create a task:**
```bash
curl -X POST http://localhost:3000/api/tasks \
  -H "Content-Type: application/json" \
  -d '{"title":"Demo Task","description":"Testing the API"}'
```

**List tasks:**
```bash
curl http://localhost:3000/api/tasks | jq
```

**Update task:**
```bash
curl -X PUT http://localhost:3000/api/tasks/1 \
  -H "Content-Type: application/json" \
  -d '{"completed":true}'
```

**Delete task:**
```bash
curl -X DELETE http://localhost:3000/api/tasks/1
```

### Database Testing

**Connect to database (UBI):**
```bash
podman exec -it demo-db-ubi psql -U taskuser -d taskdb
```

**Connect to database (RHHI - no shell!):**
```bash
podman exec -it demo-db-rhhi psql -U postgres
```

**View tasks:**
```sql
SELECT * FROM tasks ORDER BY created_at DESC;
```

## 🔧 Troubleshooting

### Container Won't Start

**Check logs:**
```bash
podman logs demo-webapp-ubi
sudo journalctl -u demo-webapp-ubi.service
```

**Check health:**
```bash
podman inspect demo-webapp-ubi | jq '.[0].State.Health'
```

**Common issues:**
- Database not ready → wait longer (15s)
- Secret not created → run deploy script
- Port already in use → check `podman ps`

### Database Connection Failures

**Verify database is running:**
```bash
podman ps | grep demo-db
podman exec demo-db-ubi pg_isready -U taskuser -d taskdb
```

**Check network:**
```bash
podman network inspect demo-net
```

**Verify secret:**
```bash
podman secret ls | grep demo-postgres-password
```

### RHHI Distroless Debugging

**No shell access:**
```bash
# ❌ Won't work
podman exec -it demo-webapp-rhhi bash

# ✅ Use debugging sidecar
podman run --rm -it --network container:demo-webapp-rhhi \
  registry.access.redhat.com/ubi9/ubi-minimal bash

# Inside sidecar:
curl http://localhost:3000/health
```

**View logs only:**
```bash
podman logs demo-webapp-rhhi -f
```

## 📈 Metrics & Comparison

### Image Sizes

| Image | UBI | RHHI | Improvement |
|-------|-----|------|-------------|
| **webapp** | 150 MB | 44 MB | **70% smaller** |
| **database** | 120 MB | 56 MB | **53% smaller** |
| **Total** | 270 MB | 100 MB | **63% smaller** |

### CVE Counts (as of 2026-06-16)

| Image | UBI | RHHI | Improvement |
|-------|-----|------|-------------|
| **webapp** | ~100 CVEs | 17 CVEs | **83% fewer** |
| **database** | ~20 CVEs | **0 CVEs** | **100% fewer** 🎉 |
| **Total** | ~120 CVEs | 17 CVEs | **86% fewer** |

### Build Times (multi-arch, local)

- **UBI webapp**: ~5 minutes
- **RHHI webapp**: ~5 minutes
- **UBI database**: ~3 minutes
- **RHHI database**: ~3 minutes

*Note: Times on M1 Mac, native build. Cross-compilation adds ~2-3x overhead.*

## 🎓 Learning Resources

### Documentation
- `webapp/ubi/README.md` - UBI webapp details
- `webapp/rhhi/README.md` - RHHI webapp details
- `database/ubi/README.md` - UBI database details
- `database/rhhi/README.md` - RHHI database details

### Architecture Diagrams
- `architecture/system-diagram.mmd` ([PNG](architecture/system-diagram.png)) - Overall architecture
- `architecture/build-pipeline.mmd` ([PNG](architecture/build-pipeline.png)) - Build workflow
- `architecture/deployment-flow.mmd` ([PNG](architecture/deployment-flow.png)) - Deployment sequence
- `architecture/network-topology.mmd` ([PNG](architecture/network-topology.png)) - Network routing
- `architecture/pipeline-comparison.mmd` ([PNG](architecture/pipeline-comparison.png)) - **Local vs CI/CD comparison**

### Presentation
- `slides/demo-presentation.md` - Complete slide deck (reveal.js compatible)

### External Resources
- [Hummingbird Catalog](https://catalog.hummingbird-project.io)
- [Hummingbird API](https://api-hummingbird.hummingbird-project.io/v1/docs/)
- [Red Hat UBI Catalog](https://catalog.redhat.com/software/base-images)
- [Container Security Scanning Guide](../docs/02-guides/container-security-scanning.md)

## 🧹 Cleanup

**Remove all demo resources:**
```bash
./scripts/cleanup-demo.sh all
```

**Remove specific variant:**
```bash
./scripts/cleanup-demo.sh ubi
./scripts/cleanup-demo.sh rhhi
```

**Remove data and secrets:**
```bash
rm -rf /home/jkirklan/demo-data/
podman secret rm demo-postgres-password
```

**Remove images:**
```bash
podman rmi ghcr.io/jkirklan/demo-webapp-ubi:latest
podman rmi ghcr.io/jkirklan/demo-db-ubi:latest
podman rmi ghcr.io/jkirklan/demo-webapp-rhhi:latest
podman rmi ghcr.io/jkirklan/demo-db-rhhi:latest
```

## 🤝 Contributing

This is a demonstration environment. To adapt for your own use:

1. **Fork** the homelab repository
2. **Modify** source code in `demo/webapp/src/`
3. **Rebuild** with `./scripts/build-demo-*.sh`
4. **Test** with `./scripts/demo-tests.sh`
5. **Deploy** with `./scripts/deploy-demo-*.sh`

## 📜 License

Part of the homelab repository. See root LICENSE file.

## 🙋 Support

For questions or issues:
- **Homelab Issues**: github.com/jkirklan/homelab/issues
- **Hummingbird**: https://gitlab.com/redhat/hummingbird/containers/-/issues
- **UBI**: Red Hat support portal

## ✨ Credits

- **UBI**: Red Hat Universal Base Images team
- **Hummingbird**: Red Hat Hummingbird Project
- **Homelab**: Built with security-first principles

---

**Built with ❤️ for security-conscious container deployments**
