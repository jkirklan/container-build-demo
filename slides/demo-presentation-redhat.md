# Container build pipeline demo
## UBI vs RHHI security-first comparison

---

## Today's agenda

- What we built
- Security-first pipeline
- Two approaches: UBI vs RHHI
- Results and trade-offs
- Live demo
- Questions

**Time:** 30-45 minutes

---

## What we built

**Simple task tracker application**

- Node.js 20 + Express.js frontend
- PostgreSQL database backend
- CRUD operations (create, read, update, delete tasks)

**Built two ways to compare:**

- **UBI Minimal** - RHEL 9 minimal base images (enterprise)
- **RHHI** - Red Hat Hardened Images (distroless)

**Purpose:** Demonstrate security-first build pipelines and compare enterprise vs distroless approaches

---

## System architecture

![System Diagram](architecture/system-diagram.png)

---

## Security-first build pipeline

**Every build goes through automated security gates:**

- Multi-stage build (build tools stay out of production)
- npm audit (fails on HIGH/CRITICAL vulnerabilities)
- Multi-architecture (AMD64 + ARM64 support)
- Trivy secret scan (detects hardcoded credentials, fails build)
- Trivy CVE scan (post-build vulnerability scanning)
- SBOM generation (supply chain transparency)

**Philosophy:** Security is not optional, it's automated in the build process

---

## Security gates example

```bash
# Gate 1: npm audit (fails on HIGH/CRITICAL)
RUN npm audit --production --audit-level=high || \
    (echo "ERROR: Vulnerabilities found" && exit 1)

# Gate 2: Secret scan (fails on secrets found)
trivy image --scanners secret ghcr.io/demo:latest

# Gate 3: CVE scan (reports but doesn't block)
trivy image --severity HIGH,CRITICAL ghcr.io/demo:latest

# Gate 4: SBOM generation
trivy image --format cyclonedx --output sbom.json
```

**Result:** Only secure images without secrets reach production

---

## UBI: RHEL Universal Base Images

**What is UBI?**

- RHEL 7, 8, 9, 10 base images
- Three flavors: Standard, Minimal, Micro (distroless)
- Package manager: microdnf (minimal) or none (micro)
- Enterprise support, 10-year lifecycle per version
- Use case: Production, regulated industries

**Strengths:**

- Enterprise support (Red Hat backing)
- Stability (10-year lifecycle)
- Compliance (FIPS, Common Criteria)
- Tooling (package manager, debugging tools)

---

## UBI: RHEL Universal Base Images

**Trade-offs:**

- Larger size (more packages = bigger images)
- More CVEs (package manager adds attack surface)

**Best for:**

- Production applications
- Regulated industries (finance, healthcare)
- Large organizations with Red Hat partnerships
- Teams new to containers

---

## RHHI: Red Hat Hardened Images

**What is RHHI?**

- Fedora Hummingbird (minimal distroless)
- No package manager (distroless design)
- Community-supported, rolling releases
- Use case: Microservices, security-first apps

**Strengths:**

- Minimal attack surface (no shell, no package manager)
- Smaller size (58% reduction vs UBI)
- Fewer CVEs (distroless = minimal vulnerabilities)
- Modern stack (PostgreSQL 17 vs 15)

---

## RHHI: Red Hat Hardened Images

**Trade-offs:**

- No shell (harder to debug)
- No package manager (everything via multi-stage builds)
- Community support (no enterprise SLA)

**Best for:**

- Security-critical applications
- Microservices architecture
- Edge computing and IoT
- Bandwidth-constrained environments

---

## Head-to-head comparison

| Feature | UBI | RHHI |
|---------|-----|------|
| Base OS | RHEL 7-10 | Fedora Hummingbird |
| Flavors | Standard, Minimal, Micro | Distroless only |
| Web app size | 245 MB | **128 MB** (48% smaller) |
| DB size | 401 MB | **144 MB** (64% smaller) |
| Total size | 645 MB | **276 MB** (58% smaller) |
| Web app CVEs | 7 | **Minimal** |
| DB CVEs | Minimal | **Minimal** |
| Package manager | microdnf (minimal) | None |
| Shell access | bash (standard/minimal) | None |
| Support | Enterprise | Community |
| Lifecycle | 10 years per version | Rolling |

---

## When to choose UBI

**Choose UBI when you need:**

- Enterprise support (Red Hat SLA and support contracts)
- Compliance requirements (FIPS 140-2, Common Criteria)
- Long-term stability (10-year lifecycle guarantees)
- Debugging tools (shell access, package manager)
- Team familiarity (standard RHEL tooling)

---

## When to choose RHHI

**Choose RHHI when you need:**

- Minimal attack surface (security-first architecture)
- Smaller images (faster deployments, less bandwidth)
- Modern stack (latest software versions)
- Cloud-native (Kubernetes, microservices)

---

## Real results

**UBI stack (using UBI 9 Minimal):**

- Build time: ~8 minutes (multi-arch)
- Web app: 245 MB (nodejs-20-minimal), 7 CVEs
- Database: 401 MB (postgresql-15 official), minimal CVEs
- Total: 645 MB

**RHHI stack:**

- Build time: ~8 minutes (multi-arch)
- Web app: 128 MB, minimal CVEs (distroless)
- Database: 144 MB, minimal CVEs (distroless)
- Total: 276 MB

**Improvement:** 58% smaller, minimal attack surface

---

## Live demo

**Demo deployed to kvm151:**

**RHHI stack:**

- Access: http://192.168.1.151:3001/health
- Status: Running with database connected

**Demo highlights:**

- Health check endpoint
- CRUD operations (create, read, update tasks)
- Container sizes vs traditional images
- Security scan results

---

## Key takeaways

- **Security first** - Automated gates catch issues before deployment
- **Not either/or** - Use the right tool for the job
- **Size matters** - 58% reduction with RHHI enables new use cases
- **Trade-offs** - Debuggability vs security, support vs flexibility
- **Multi-arch** - Same code, both AMD64 and ARM64

**The future:** Mix and match based on workload needs, not one-size-fits-all

---

## Resources

**Demo repository:**

- GitHub: `jkirklan/homelab/demo/`
- Includes: Containerfiles, build scripts, deployment configs

**Documentation:**

- Build pipeline diagrams
- Security scanning guides
- Deployment procedures
- Test results

**Get started:**

```bash
git clone https://github.com/jkirklan/homelab.git
cd homelab/demo/
make ubi    # Build UBI stack
make rhhi   # Build RHHI stack
```

---

## Questions?

**Happy to discuss:**

- Security scanning strategies
- Container optimization techniques
- Multi-architecture builds
- UBI vs RHHI trade-offs
- Podman + systemd deployment
- Anything else

**Contact:** Available after the presentation

---

# Thank you
## Security-first container builds

**Remember:**

- Automate security scanning
- Choose the right base for your needs
- Build multi-arch from the start
- Test your builds locally

**Demo:** http://192.168.1.151:3001

**Questions:** Let's discuss
