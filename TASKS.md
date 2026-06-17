# Container Build Demo - Task Tracking

This file tracks completed and pending tasks for the container build demo project.

## Active Tasks

Use Claude Code task system (`TaskCreate`, `TaskUpdate`, `TaskList`) for active work.

## Completed Tasks

### 2026-06-17 - Initial Demo Creation

**Task:** Build UBI vs RHHI comparison demo
- Created task tracker application (Node.js + PostgreSQL)
- Built UBI variant (245 MB webapp, 401 MB database)
- Built RHHI variant (128 MB webapp, 144 MB database)
- Implemented security scanning pipeline (npm audit, Trivy, SBOM)
- Multi-architecture builds (AMD64 + ARM64)
- Deployed to kvm151 for testing
- **Result:** 58% size reduction, minimal CVEs with RHHI

**Task:** Create presentation materials
- Built reveal.js presentations (full, short, Red Hat branded)
- Created 5 Mermaid diagrams (system, build, deployment, network, comparison)
- Rendered diagrams to PNG for slides
- Developed Red Hat brand-compliant theme (fonts, colors, spacing)
- Fixed multiple slide overflow issues
- Created comprehensive README and documentation
- **Result:** 3 presentation versions ready for technical talks

**Task:** Add bootc variant
- Created bootc Containerfile (CentOS Stream 9 base)
- Designed systemd service architecture
- Documented bootc deployment approaches
- Added third paradigm to comparison table
- **Status:** Containerfile complete, testing in progress

### 2026-06-16 - Testing and Documentation

**Task:** Comprehensive testing and metrics
- Performed local testing on Mac (non-systemd)
- Generated test results documentation
- Created SBOM files for RHHI variants
- Documented pipeline comparison (local vs CI/CD)
- Created npm malware detection guide
- **Result:** Complete test documentation suite

## Pending Tasks

### High Priority

- [ ] **Complete bootc testing** - Test bootc image build and deployment
- [ ] **GitHub Actions CI/CD** - Multi-arch builds + GHCR push
- [ ] **Demo video/recording** - Record presentation walkthrough
- [ ] **Publish to GHCR** - Push all variants to GitHub Container Registry

### Medium Priority

- [ ] **Kubernetes deployment** - Add k8s manifests for all variants
- [ ] **Performance benchmarks** - Startup time, memory usage comparison
- [ ] **Advanced security** - Add Falco, seccomp profiles, AppArmor
- [ ] **Monitoring integration** - Prometheus metrics, Grafana dashboards

### Low Priority / Future

- [ ] **Additional variants** - Alpine, Wolfi, Chainguard
- [ ] **ARM-only variant** - Optimize for edge/IoT devices
- [ ] **Database alternatives** - MySQL, MongoDB variants
- [ ] **Language variants** - Python, Go, Rust versions of the app

See `backlog.md` for detailed future enhancement ideas.

## Task Archive

For historical task tracking from when this was part of the homelab repo, see:
- Homelab repo: `https://github.com/jkirklan/homelab/blob/main/TASKS.md`
- Tasks #70-71 (presentation and bootc work)

---

**Note:** This demo was extracted from the homelab repo on 2026-06-17 to become a standalone educational project.
