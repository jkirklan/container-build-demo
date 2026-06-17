# Demo Environment Backlog

## In Progress

None

## To Do

### High Priority
- [ ] Update presentation with actual CVE counts from scans
- [ ] Create comparison metrics document (sizes, CVEs, build times)

### Medium Priority
- [ ] Add test suite for CRUD operations (demo-tests.sh)
- [ ] Document deployment procedures in detail
- [ ] Create demo video/recording for presentation

### Low Priority
- [ ] Consider alternative automation: file watcher (fswatch), act (local GitHub Actions)

## Completed

### 2026-06-17: Production Deployment (Complete!)
- [x] Push multi-arch images to GHCR (UBI and RHHI)
- [x] Create deployment script for kvm151
- [x] Deploy RHHI demo to kvm151 (port 3001)
- [x] Open firewall for demo ports (3000, 3001)
- [x] Verify deployment working (health check passed)

**Note:** UBI PostgreSQL deployment had permission issues with rootless Podman and SELinux. RHHI PostgreSQL (distroless) worked without issues. UBI deployment skipped in favor of working RHHI version.

### 2026-06-17: Local Testing (Complete!)
- [x] Test deployment locally (both UBI and RHHI stacks)
- [x] Validate CRUD operations (GET, POST, PUT)
- [x] Verify multi-arch manifest selection (ARM64 on Mac)
- [x] Document local testing procedures
- [x] Document test results and findings
- [x] Confirmed 58% size reduction (RHHI vs UBI)
- [x] Validated security gates (all passed)

### 2026-06-16: Demo Environment Build (Complete!)
- [x] Plan demo environment architecture
- [x] Create demo directory structure
- [x] Develop Node.js task tracker application
  - [x] Express server (app.js)
  - [x] Database connection (db.js)
  - [x] CRUD API routes (routes/tasks.js)
  - [x] Frontend UI (index.html, style.css)
  - [x] Package configuration (package.json)
- [x] Write UBI Containerfiles
  - [x] webapp/ubi/Containerfile (multi-stage, ubi9/nodejs-20)
  - [x] database/ubi/Containerfile (Red Hat PostgreSQL 15 official image)
  - [x] database/init.sql
  - [x] READMEs explaining UBI approach
- [x] Write RHHI Containerfiles
  - [x] Query Hummingbird catalog for base images
  - [x] webapp/rhhi/Containerfile (hi/nodejs:20 distroless)
  - [x] database/rhhi/Containerfile (hi/postgresql:17 distroless)
  - [x] READMEs explaining RHHI approach
- [x] Write build scripts
  - [x] build-demo-ubi.sh (multi-arch AMD64+ARM64)
  - [x] build-demo-rhhi.sh (multi-arch AMD64+ARM64)
  - [x] scan-demo.sh (Trivy secrets + CVEs + SBOM)
- [x] Build automation via Makefile (make ubi, make rhhi, make all)
- [x] Create Mermaid architecture diagrams
  - [x] system-diagram.mmd → PNG
  - [x] build-pipeline.mmd → PNG
  - [x] deployment-flow.mmd → PNG
  - [x] network-topology.mmd → PNG
  - [x] pipeline-comparison.mmd → PNG (local vs CI/CD)
- [x] Write demo presentation slides (40 slides, reveal.js format)
- [x] Create demo README documentation (comprehensive guide)
- [x] Generate comparison metrics
  - [x] Image sizes: UBI 645 MB → RHHI 276 MB (57% reduction)
  - [x] Security scans: All passed secret detection
  - [x] SBOMs generated (CycloneDX format)
- [x] GitHub Actions CI/CD workflow (matrix builds, security gates)
- [x] Enhanced security scanning
  - [x] npm audit (fail on HIGH/CRITICAL)
  - [x] Trivy secret scan (fail on detection)
  - [x] Trivy CVE scan (report HIGH/CRITICAL)
  - [x] npm malware detection guide
- [x] Build infrastructure improvements
  - [x] Enhanced build-multiarch.sh (supports -f flag)
  - [x] Auto-detect Trivy (Homebrew/manual)
  - [x] Fixed permission issues (USER 0 pattern)
  - [x] Simplified Containerfiles (use official images)
