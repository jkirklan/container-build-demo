# Container Build Pipeline Demo
## Three RHEL Deployment Paradigms

<div style="position: absolute; bottom: 20px; right: 20px; font-size: 0.6em; color: #888;">
Version 1.0 | 2026-06-18
</div>

---

## 👋 Today's Agenda (30-45 min)

1. **What We Built** - Simple task tracker
2. **Security-First Pipeline** - How we ensure security
3. **Three Paradigms** - UBI vs RHHI vs bootc
4. **Results & Trade-offs** - When to use each
5. **Live Demo** - See it in action
6. **Q&A**

---

## 🏗️ What We Built

**Simple Task Tracker Application**

- **Frontend**: Node.js 20 + Express.js
- **Backend**: PostgreSQL database
- **Purpose**: CRUD operations (Create/Read/Update/Delete tasks)

**Built THREE ways to demonstrate RHEL's deployment ecosystem:**
- **UBI** (Universal Base Images) - Enterprise containers
- **RHHI** (Red Hat Hardened Images) - Distroless containers
- **bootc** (Image Mode) - Bootable OS images

**Why?** To demonstrate security-first pipelines across all three modern RHEL deployment tracks.

---

## 📊 System Architecture

<div style="text-align: center;">

![System Diagram](architecture/system-diagram.png)

</div>

**Three Modern RHEL Deployment Tracks:**

1. **Container-native** - UBI & RHHI (Podman + systemd quadlets)
2. **Image mode / bootc** - Bootable OS images (immutable infrastructure)
3. **Traditional RPMs** - Package-based (legacy approach)

**This demo covers tracks 1 & 2 with the same application!**

---

## 🔒 Security-First Build Pipeline

**Every build goes through automated security gates:**

1. **📦 Multi-stage Build** - Build tools stay out of production
2. **🔍 npm audit** - Fails on HIGH/CRITICAL vulnerabilities
3. **🏗️ Multi-architecture** - AMD64 + ARM64 support
4. **🔐 Trivy Secret Scan** - Detects hardcoded credentials (FAILS build)
5. **🛡️ Trivy CVE Scan** - Post-build vulnerability scanning
6. **📋 SBOM Generation** - Supply chain transparency

**Philosophy**: Security is not optional, it's automated in the build process.

---

## 🔄 Local vs CI/CD: Two Ways to Build

| Feature | 🖥️ Local Pipeline | ☁️ CI/CD Pipeline |
|---------|-------------------|-------------------|
| **Execution** | Manual `make ubi` | Auto on git push |
| **Speed** | ~10 min (local) | ~12 min (GitHub) |
| **Security Gates** | ✅ Same (npm audit, Trivy, SBOM) | ✅ Same |
| **Dashboard** | Terminal output | ✅ GitHub Security tab |
| **Team Visibility** | ❌ Local only | ✅ All team members |
| **Offline** | ✅ Yes | ❌ Requires internet |
| **Cost** | Free (local CPU) | GitHub Actions minutes |

**Workflow:**
- **Local**: Pre-commit → Build → Scan → Deploy → Test (fast iteration)
- **CI/CD**: Push → Matrix build → Scan → Security tab → Registry push (consistent, automated)

**Best Practice**: Local for development, CI/CD for validation and releases

---

## 🔐 Security Gates Example

```bash
# Gate 1: npm audit (FAILS on HIGH/CRITICAL)
RUN npm audit --production --audit-level=high || \
    (echo "ERROR: Vulnerabilities found" && exit 1)

# Gate 2: Secret scan (FAILS on secrets found)
trivy image --scanners secret ghcr.io/demo:latest

# Gate 3: CVE scan (reports but doesn't block)
trivy image --severity HIGH,CRITICAL ghcr.io/demo:latest

# Gate 4: SBOM generation
trivy image --format cyclonedx --output sbom.json
```

**Result**: Only secure images without secrets reach production

---

## 🟢 UBI: RHEL Universal Base Images

### What is UBI?

- **Based on**: Red Hat Enterprise Linux 9
- **Package Manager**: microdnf (minimal dnf)
- **Support**: Enterprise support available
- **Lifecycle**: 10-year support lifecycle
- **Use Case**: Production environments, regulated industries

### Pros

✅ **Enterprise Support** - Red Hat backing  
✅ **Stability** - 10-year lifecycle  
✅ **Compliance** - FIPS, Common Criteria  
✅ **Tooling** - Full package manager, debugging tools  

### Cons

⚠️ **Larger Size** - More packages = bigger images  
⚠️ **More CVEs** - Package manager adds attack surface

---

## 🔵 RHHI: Red Hat Hardened Images (RHHI)

### What is (RHHI)?

- **Based on**: Fedora (minimal distroless)
- **Package Manager**: None (distroless)
- **Support**: Community-supported
- **Lifecycle**: Rolling releases
- **Use Case**: Microservices, security-first apps

### Pros

✅ **Minimal Attack Surface** - No shell, no package manager  
✅ **Smaller Size** - 58% reduction vs UBI  
✅ **Fewer CVEs** - Distroless = minimal vulnerabilities  
✅ **Modern Stack** - Latest versions (PostgreSQL 17 vs 15)  

### Cons

⚠️ **No Shell** - Harder to debug  
⚠️ **No Package Manager** - Everything via multi-stage builds  
⚠️ **Community Support** - No enterprise SLA

---

## 🟣 bootc: Image Mode / Bootable Containers

### What is bootc?

- **Type**: Bootable OS image (not just an app container)
- **Base**: RHEL 9 Image Mode bootc
- **Deployment**: Bare metal or VM (boots as the OS)
- **Use Case**: Appliances, edge devices, immutable infrastructure

### Pros

✅ **Immutable Infrastructure** - OS + app versioned together  
✅ **Atomic Updates** - Full system upgrade with rollback  
✅ **Edge Ready** - Single image for remote systems  
✅ **Appliance Model** - Purpose-built, self-contained systems  

### Cons

⚠️ **Large Size** - ~1-2 GB (full OS, not minimal)  
⚠️ **Requires Reboot** - Updates need system restart  
⚠️ **Not Multi-Tenant** - One app per OS instance

---

## 📊 Three-Way Comparison

| **Feature** | **UBI** | **RHHI** | **bootc** |
|-------------|---------|----------|-----------|
| **Type** | App container | App container | Bootable OS |
| **Base OS** | RHEL 9 | Fedora | RHEL 9 Image Mode |
| **Total Size** | 645 MB | **276 MB** ⭐ | ~1-2 GB |
| **CVEs** | Moderate | **Minimal** ⭐ | Moderate |
| **Package Manager** | microdnf ✅ | None | None (immutable) |
| **Shell Access** | bash ✅ | None | SSH (post-boot) |
| **Deployment** | Podman | Podman | Bare metal / VM |
| **Updates** | Pull + restart | Pull + restart | bootc + reboot |
| **Support** | Enterprise ✅ | Community | Enterprise (RHEL variant) |
| **Isolation** | Process | Process | Full system |
| **Best For** | General apps | Microservices | Edge / appliances |

---

## 🎯 When to Choose UBI

**Choose UBI when you need:**

✅ **Enterprise Support** - Red Hat SLA and support contracts  
✅ **Compliance Requirements** - FIPS 140-2, Common Criteria  
✅ **Long-Term Stability** - 10-year lifecycle guarantees  
✅ **Debugging Tools** - Shell access, package manager  
✅ **Team Familiarity** - Standard RHEL tooling  

**Perfect for:**
- Production applications
- Regulated industries (finance, healthcare)
- Large organizations with Red Hat partnerships
- Teams new to containers

---

## 🎯 When to Choose RHHI

**Choose RHHI when you need:**

✅ **Minimal Attack Surface** - Security-first architecture  
✅ **Smaller Images** - Faster deployments, less bandwidth  
✅ **Modern Stack** - Latest software versions  
✅ **Cloud-Native** - Kubernetes, microservices  

**Perfect for:**
- Security-critical applications
- Microservices architecture
- Cloud-native workloads
- Bandwidth-constrained environments

---

## 🎯 When to Choose bootc

**Choose bootc when you need:**

✅ **Immutable Infrastructure** - OS + app as single artifact  
✅ **Edge Deployments** - Remote, single-purpose systems  
✅ **Appliances** - Kiosks, IoT gateways, embedded systems  
✅ **Atomic Updates** - Full system rollback capability  

**Perfect for:**
- Edge computing locations
- Appliance-style deployments
- Immutable infrastructure requirements
- Systems needing OS-level control

---

## 📈 Real Results

### UBI Stack:
- **Build time**: ~8 minutes (multi-arch)
- **Total size**: 645 MB (webapp + database)
- **CVEs**: 7 (webapp), Minimal (database)

### RHHI Stack:
- **Build time**: ~6 minutes (multi-arch)
- **Total size**: 276 MB (58% smaller! ⭐)
- **CVEs**: Minimal (distroless)

### bootc Image:
- **Build time**: ~11 minutes (AMD64)
- **Total size**: ~1-2 GB (full OS + app)
- **CVEs**: Moderate (full OS)

**Key insight**: Choose based on deployment model, not just size!

---

## 🚀 Live Demo

**Live Dashboard: http://localhost:8888**

Watch all three paradigms build in parallel!

**What you'll see:**
1. **UBI** - Traditional enterprise containers
2. **RHHI** - Distroless security-hardened containers
3. **bootc** - Bootable OS image

**Real-time updates:**
- Build progress (init → build → scan)
- Live log streaming
- Duration tracking
- Success/failure status

**One command:** `make demo`

---

## 💡 Key Takeaways

1. **Three Paradigms** - UBI (enterprise), RHHI (distroless), bootc (immutable OS)
2. **Security First** - Same security pipeline for all three tracks
3. **Right Tool for Job** - Containers for apps, bootc for appliances
4. **Size vs Scope** - RHHI smallest (276 MB), bootc largest (~2 GB) but includes OS
5. **Multi-arch** - UBI and RHHI support AMD64 + ARM64
6. **Live Dashboard** - Parallel builds with real-time progress

**The Future**: Red Hat's multi-modal deployment ecosystem - choose what fits!

---

## 🔗 Resources

**Demo Repository:**
- GitHub: `jkirklan/homelab/demo/`
- Includes: Containerfiles, build scripts, deployment configs

**Documentation:**
- Build pipeline diagrams
- Security scanning guides
- Deployment procedures
- Test results

**Get Started:**
```bash
git clone https://github.com/jkirklan/homelab.git
cd homelab/demo/
make ubi     # Build UBI stack
make rhhi    # Build RHHI stack
make bootc   # Build bootc image
make demo    # Live dashboard + parallel builds
```

---

## ❓ Questions?

**Happy to discuss:**
- Security scanning strategies
- Container optimization techniques
- Multi-architecture builds
- UBI vs RHHI trade-offs
- Podman + systemd deployment
- Anything else!

**Contact:** Available after the presentation

---

# Thank You! 🎉
## Security-First Container Builds

**Remember:**
- Automate security scanning
- Choose the right base for your needs
- Build multi-arch from the start
- Test your builds locally

🔗 **Demo:** http://192.168.1.151:3001  
📧 **Questions:** Let's discuss!
