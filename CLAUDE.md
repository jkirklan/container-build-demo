# Claude Code Instructions for Container Build Demo

## Project Overview

This is a **standalone educational demo** showcasing three container deployment paradigms:
- **UBI** - RHEL Universal Base Images (enterprise containers)
- **RHHI** - Red Hat Hardened Images (distroless containers)  
- **Bootc** - Bootable container images (immutable OS)

**Purpose:** Demonstrate security-first build pipelines, compare deployment approaches, and provide a complete presentation for technical talks.

**Audience:** Technical presentations, conference talks, security teams, platform engineers

## Repository Structure

```
container-build-demo/
├── README.md                      # Main documentation
├── CLAUDE.md                      # This file
├── TASKS.md                       # Task tracking
├── Makefile                       # Build automation
├── backlog.md                     # Future enhancements
├── webapp/                        # Application source
│   ├── src/                       # Shared Node.js app
│   ├── ubi/Containerfile          # UBI build
│   ├── rhhi/Containerfile         # RHHI build
│   └── package.json               # Dependencies
├── database/                      # Database containers
│   ├── ubi/Containerfile          # PostgreSQL UBI
│   └── rhhi/Containerfile         # PostgreSQL RHHI
├── bootc/                         # Bootable OS variant
│   ├── Containerfile              # Full OS image
│   ├── README.md                  # Bootc documentation
│   └── build.sh                   # Build script
├── slides/                        # Reveal.js presentations
│   ├── demo-presentation.md       # Full version (30 slides)
│   ├── demo-presentation-short.md # Short version (18 slides)
│   ├── demo-presentation-redhat.md # Red Hat branded
│   ├── redhat-theme.css           # Custom theme
│   ├── redhat-style-guide.md      # Branding reference
│   └── architecture/              # Diagrams (mermaid + PNG)
├── scripts/                       # Build and deployment
├── quadlets/                      # Podman systemd units
├── sboms/                         # Software Bill of Materials
└── docs/                          # Additional documentation
```

## Quick Reference

### Build Commands

```bash
# Build UBI stack
make ubi

# Build RHHI stack
make rhhi

# Build all variants
make all

# Build bootc image
cd bootc && ./build.sh

# Clean all images
make clean
```

### Testing Locally

See `docs/local-testing.md` for Mac/non-systemd testing instructions.

### Presentation

```bash
cd slides/
./serve.sh 8080
# Open: http://localhost:8080/index-redhat.html
```

## Development Workflow

### Making Changes

1. **Application code** - Edit `webapp/src/` (shared across all variants)
2. **Container builds** - Modify `webapp/{ubi,rhhi}/Containerfile` or `database/{ubi,rhhi}/Containerfile`
3. **Bootc** - Edit `bootc/Containerfile` (OS-level changes)
4. **Presentation** - Update `slides/*.md` files

### Testing Changes

1. Build locally: `make ubi` or `make rhhi`
2. Run security scans: `./scripts/scan-demo.sh`
3. Test deployment: `./scripts/deploy-demo-{ubi,rhhi}.sh`
4. Verify metrics match presentation claims

### Before Committing

- [ ] Run `make all` to verify all variants build
- [ ] Update presentation if metrics changed
- [ ] Run security scans (npm audit, trivy)
- [ ] Update SBOMs if dependencies changed
- [ ] Test presentation slides render correctly
- [ ] Update README if architecture changed

## Security Standards

**All container builds MUST include:**

1. **npm audit** - Fails on HIGH/CRITICAL vulnerabilities
   ```dockerfile
   RUN npm audit --production --audit-level=high || \
       (echo "ERROR: Vulnerabilities found" && exit 1)
   ```

2. **Multi-stage builds** - Build tools separate from runtime
3. **Non-root users** - Never run as root in production
4. **Trivy scanning** - Post-build CVE and secret scans
5. **SBOM generation** - Track supply chain dependencies

## Presentation Guidelines

### Red Hat Brand Compliance

When using the Red Hat branded slides (`index-redhat.html`):

- ✅ **Sentence case only** - Never Title Case or ALL CAPS
- ✅ **Red Hat fonts** - Display (headings), Text (body), Mono (code)
- ✅ **Color palette** - Red (#ee0000) used sparingly as accents
- ✅ **Generous white space** - Don't clutter slides
- ✅ **WCAG 2.1 AA** - 4.5:1 contrast ratio minimum

See `slides/redhat-style-guide.md` for complete brand standards.

### Updating Metrics

**CRITICAL:** Presentation metrics MUST match actual test results.

When container sizes or CVE counts change:
1. Rebuild and scan: `./scripts/scan-demo.sh`
2. Update `docs/test-results.md` with actual numbers
3. Update ALL presentation files with new metrics:
   - `slides/demo-presentation.md`
   - `slides/demo-presentation-short.md`
   - `slides/demo-presentation-redhat.md`
4. Re-render diagrams: `cd slides/architecture && mmdc -i *.mmd -o *.png`
5. Verify slides display correctly

## Architecture Decisions

### Why Three Variants?

Each demonstrates a different deployment paradigm:

**UBI (Universal Base Images):**
- Traditional application containers
- Enterprise support, 10-year lifecycle
- Full tooling (package manager, shell, debugging)
- Use case: Production apps, regulated industries

**RHHI (Red Hat Hardened Images):**
- Distroless application containers
- Minimal attack surface (no shell, no package manager)
- 58% smaller than UBI
- Use case: Security-first apps, microservices

**Bootc (Bootable Containers):**
- Full OS images (not app containers)
- Immutable infrastructure
- Deploy as VM or bare metal
- Use case: Appliances, edge, atomic updates

### Multi-Architecture Support

All images build for AMD64 + ARM64:
- Enables Mac development (ARM64)
- Deploys to x86 servers (AMD64)
- Uses `podman buildx` or `build-multiarch.sh`

## Common Patterns

### Container Build Pattern

```dockerfile
# Stage 1: Builder
FROM base-image AS builder
USER 0  # UBI/RHHI default to non-root
WORKDIR /build
COPY package*.json ./
RUN npm audit --production --audit-level=high || exit 1
RUN npm ci
COPY src/ ./src/

# Stage 2: Runtime
FROM minimal-base
USER 0  # For package install only
RUN microdnf install -y curl && microdnf clean all
RUN useradd -u 1000 webapp
COPY --from=builder --chown=webapp:webapp /build ./
USER 1000  # Switch to non-root
CMD ["node", "src/app.js"]
```

### Security Scanning Pattern

```bash
# Build
podman build -t demo:latest .

# Scan for secrets (FAIL on found)
trivy image --scanners secret demo:latest

# Scan for CVEs (REPORT only)
trivy image --severity HIGH,CRITICAL demo:latest

# Generate SBOM
trivy image --format cyclonedx --output sbom.json demo:latest
```

## Gotchas

### Bootc Images

- **NOT regular containers** - Bootc images are full OS images
- **Can't test with `podman run`** - Need bootc-image-builder or VM
- **Systemd services** - Initialize at boot time, not build time
- **Size expectation** - 1-2 GB (full OS) vs 276-645 MB (containers)

### Presentation Rendering

- **CORS issue** - Can't open `index.html` directly (browser blocks)
- **Must use HTTP server** - Use `./serve.sh` script
- **Image paths** - All diagrams must be in `slides/architecture/`
- **Overflow issues** - Keep slides concise, test in actual browser

### Multi-Arch Builds

- **Platform flag required** - `--platform linux/amd64,linux/arm64`
- **Cross-compilation** - Mac (ARM64) can build AMD64 with emulation
- **Build time** - Multi-arch takes ~2x single-arch build time

## Task Management

Use Claude Code task system for active work:

```
TaskCreate - Create new tasks
TaskUpdate - Update status (pending → in_progress → completed)
TaskList - View all tasks
```

Archive completed tasks in `TASKS.md` for historical reference.

## Related Resources

- **Homelab repo**: https://github.com/jkirklan/homelab (deployment target)
- **Red Hat UBI**: https://developers.redhat.com/products/rhel/ubi
- **Hummingbird**: https://access.redhat.com/products/hummingbird
- **Bootc project**: https://github.com/containers/bootc

## Getting Help

- Check `README.md` for architecture overview
- See `docs/` for detailed guides
- Review `backlog.md` for known issues and future work
- Task tracking in `TASKS.md`

---

**Last Updated:** 2026-06-17
