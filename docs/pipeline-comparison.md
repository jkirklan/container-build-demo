# Pipeline Comparison: Local vs CI/CD

Comparison of manual local pipeline execution vs automated CI/CD (GitHub Actions).

---

## Execution Models

### Local Pipeline (Manual)

**Scripts:**
- `./scripts/build-demo-ubi.sh` - Build images locally
- `./scripts/scan-demo.sh` - Security scanning
- `./scripts/deploy-demo-ubi.sh` - Deploy to kvm151

**Workflow:**
1. Developer commits code
2. Pre-commit hooks run (gitleaks)
3. Manual execution: `make ubi` or individual scripts
4. Manual deployment to target host

**Control:** Full developer control at each step

### CI/CD Pipeline (Automated)

**Trigger:** Automatic on push to `main` (when `demo/**` changes)

**GitHub Actions Workflow:** `.github/workflows/demo-pipeline.yml`

**Workflow:**
1. Git push triggers Actions
2. Matrix builds (UBI + RHHI, AMD64 + ARM64)
3. Automated security scanning (Trivy)
4. Automated SBOM generation
5. Automated push to ghcr.io
6. Security tab integration

**Control:** Fully automated, no manual steps

---

## Feature Comparison

| Feature | Local Pipeline | CI/CD Pipeline |
|---------|----------------|----------------|
| **Execution** | Manual (`make ubi`) | Automatic (on push) |
| **Speed** | Fast (local resources) | Slower (GitHub runners) |
| **Environment** | Developer workstation | Consistent GitHub runners |
| **Multi-arch** | ✅ Podman manifest | ✅ Docker Buildx matrix |
| **npm audit** | ✅ In Containerfile | ✅ In Containerfile |
| **Trivy secret scan** | ✅ Fails on HIGH/CRITICAL | ✅ Fails on HIGH/CRITICAL |
| **Trivy CVE scan** | ✅ Reports findings | ✅ Reports + Security tab |
| **SBOM generation** | ✅ Saved to `sboms/` | ✅ Uploaded as artifact |
| **Registry push** | Manual (`podman push`) | Automatic (on success) |
| **Artifact retention** | Local only | 90 days (GitHub) |
| **Security dashboard** | ❌ No | ✅ GitHub Security tab |
| **Team visibility** | ❌ Local only | ✅ All team members |
| **Offline capable** | ✅ Yes | ❌ Requires internet |
| **Cost** | Free (local resources) | GitHub runner minutes |

---

## Security Gates (Both Pipelines)

Both pipelines implement the same security gates:

### Gate 1: Pre-commit (gitleaks)
- **When:** Before commit
- **Action:** BLOCK commit if secrets detected
- **Scope:** Entire repository
- **Tool:** gitleaks via pre-commit framework

### Gate 2: npm audit (build-time)
- **When:** During container build (in Containerfile)
- **Action:** FAIL build on HIGH/CRITICAL vulnerabilities
- **Scope:** Node.js dependencies only
- **Tool:** `npm audit --production --audit-level=high`

### Gate 3: Trivy secret scan (post-build)
- **When:** After image build
- **Action:** FAIL pipeline on HIGH/CRITICAL secrets
- **Scope:** Entire container image
- **Tool:** `trivy image --scanners secret`

### Gate 4: Trivy CVE scan (post-build)
- **When:** After image build
- **Action:** REPORT findings (non-blocking)
- **Scope:** OS packages + language dependencies
- **Tool:** `trivy image --severity HIGH,CRITICAL`

### Gate 5: SBOM generation
- **When:** After successful scans
- **Action:** Generate CycloneDX SBOM
- **Scope:** All packages (runtime + build)
- **Tool:** `trivy image --format cyclonedx`

---

## Advantages & Limitations

### ✅ Local Pipeline Advantages

1. **Fast iteration** - No wait for GitHub runners
2. **Full control** - Pause/resume/debug at any step
3. **Offline capable** - Works without internet (after images cached)
4. **No runner costs** - Uses local compute resources
5. **Immediate feedback** - See results in seconds
6. **Flexible execution** - Run individual scripts or full pipeline

### ⚠️ Local Pipeline Limitations

1. **Manual execution** - Must remember to run scripts
2. **Platform-dependent** - Results vary by developer workstation
3. **No artifact storage** - SBOMs only stored locally
4. **No security dashboard** - Must read Trivy output directly
5. **No team visibility** - Only developer sees results
6. **Inconsistent environments** - Different Podman versions, etc.

### ✅ CI/CD Pipeline Advantages

1. **Automated** - Runs on every push automatically
2. **Consistent environment** - Same runners every time
3. **Security tab integration** - Centralized vulnerability dashboard
4. **Artifact retention** - SBOMs stored for 90 days
5. **Team visibility** - All team members see build status
6. **Matrix builds** - Parallel builds for all variants
7. **Audit trail** - Complete history in GitHub Actions

### ⚠️ CI/CD Pipeline Limitations

1. **Slower feedback** - Wait for runner availability
2. **Requires internet** - Cannot run offline
3. **Runner costs** - Consumes GitHub Actions minutes
4. **Less flexible** - Cannot easily pause/debug mid-pipeline
5. **Network-dependent** - Registry pushes require stable connection

---

## When to Use Each

### Use Local Pipeline When:

- **Rapid development** - Testing changes quickly
- **Debugging builds** - Need to inspect intermediate steps
- **Offline work** - No internet connection available
- **Cost-sensitive** - Avoiding GitHub runner charges
- **Learning** - Understanding the pipeline steps

### Use CI/CD Pipeline When:

- **Production releases** - Final validation before deployment
- **Team collaboration** - Multiple developers working on codebase
- **Compliance** - Need audit trail and artifact retention
- **Security monitoring** - Centralized vulnerability tracking
- **Automated deployment** - Trigger deployments from successful builds

---

## Recommended Workflow

**Development cycle:**
1. Use **local pipeline** for rapid iteration during development
2. Push to GitHub when ready for team review
3. **CI/CD pipeline** runs automatically for validation
4. Team reviews Security tab findings
5. Deploy from validated CI/CD artifacts

**Best of both worlds:**
- Fast local feedback during development
- Consistent validation and team visibility via CI/CD

---

## Metrics Comparison (2026-06-17)

### Local Pipeline (Mac M1 ARM64)

| Metric | UBI | RHHI |
|--------|-----|------|
| **Build time** | ~8 min | ~8 min |
| **Image size** | 673 MB | 285 MB |
| **Scan time** | ~2 min | ~2 min |
| **Total time** | ~10 min | ~10 min |

**Total pipeline:** ~10 minutes per variant (build + scan)

### CI/CD Pipeline (GitHub Actions)

| Metric | Value |
|--------|-------|
| **Matrix jobs** | 4 (UBI+RHHI × AMD64+ARM64) |
| **Parallel execution** | Yes (all jobs run concurrently) |
| **Total time** | ~12 min (including runner startup) |
| **Artifact retention** | 90 days |

**Total pipeline:** ~12 minutes for all variants (parallel)

---

## Cost Analysis

### Local Pipeline

**Cost:** $0 (uses developer workstation)

**Resource usage:**
- CPU: 100% during builds (~8 minutes per variant)
- Memory: ~4 GB peak
- Disk: ~1 GB per variant (images + SBOMs)
- Network: Registry pulls only (cached after first run)

### CI/CD Pipeline

**Cost:** GitHub Actions minutes (included in free tier or organization plan)

**GitHub Actions usage:**
- ~12 minutes per pipeline run (all variants parallel)
- Approximately ~50-60 minutes/month (daily pushes)
- Well within free tier (2000 minutes/month for public repos)

**Resource usage:**
- Managed by GitHub (no local impact)
- Network: Higher (pulls + pushes on every run)

---

## Security Posture (Both Equal)

Both pipelines implement **identical security gates**:

✅ Pre-commit secret detection (gitleaks)
✅ Build-time dependency audit (npm)
✅ Post-build secret scan (Trivy)
✅ CVE vulnerability scan (Trivy)
✅ SBOM generation (CycloneDX)

**Key difference:**
- Local: Security findings in terminal output
- CI/CD: Security findings in GitHub Security tab (better visibility)

---

## Conclusion

**Both pipelines are production-ready** with identical security controls.

**Choose based on context:**
- **Local:** Fast iteration, learning, offline work
- **CI/CD:** Team visibility, compliance, automated releases

**Recommended:** Use both - local for development, CI/CD for validation.

---

**Last Updated:** 2026-06-17
