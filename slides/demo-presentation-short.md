# Container Build Pipeline Demo
## UBI vs RHHI: A Security-First Comparison

---

## 👋 Today's Agenda (30-45 min)

1. **What We Built** - Simple task tracker
2. **Security-First Pipeline** - How we ensure security
3. **Two Approaches** - UBI vs RHHI comparison
4. **Results & Trade-offs** - When to use each
5. **Live Demo** - See it in action
6. **Q&A**

---

## 🏗️ What We Built

**Simple Task Tracker Application**

- **Frontend**: Node.js 20 + Express.js
- **Backend**: PostgreSQL database
- **Purpose**: CRUD operations (Create/Read/Update/Delete tasks)

**Built TWO ways for comparison:**
- **UBI** (RHEL Universal Base Images) - Enterprise approach
- **RHHI** (Red Hat Hummingbird) - Minimal distroless approach

**Why?** To demonstrate security-first build pipelines and compare approaches for different use cases.

---

## 📊 System Architecture

![System Diagram](architecture/system-diagram.png)

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

## 🔵 RHHI: Red Hat Hummingbird Images

### What is Hummingbird?

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

## 📊 Head-to-Head Comparison

| **Feature** | **UBI** | **RHHI** |
|-------------|---------|----------|
| **Base OS** | RHEL 9 | Fedora |
| **Web App Size** | 245 MB | **128 MB** ⭐ (48% smaller) |
| **DB Size** | 401 MB | **144 MB** ⭐ (64% smaller) |
| **Total Size** | 645 MB | **276 MB** ⭐ (58% smaller) |
| **Web App CVEs** | 7 | **Minimal** ⭐ |
| **DB CVEs** | Minimal | **Minimal** ⭐ |
| **Package Manager** | microdnf ✅ | None ❌ |
| **Shell Access** | bash ✅ | None ❌ |
| **Support** | Enterprise ✅ | Community |
| **Lifecycle** | 10 years ✅ | Rolling |
| **Best For** | Production, regulated | Microservices, security |

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
- Edge computing / IoT
- Bandwidth-constrained environments

---

## 📈 Real Results

### UBI Stack:
- **Build time**: ~8 minutes (multi-arch)
- **Web app**: 245 MB, 7 CVEs
- **Database**: 401 MB, Minimal CVEs
- **Total**: 645 MB

### RHHI Stack:
- **Build time**: ~8 minutes (multi-arch)
- **Web app**: 128 MB, Minimal CVEs (distroless)
- **Database**: 144 MB, Minimal CVEs (distroless)
- **Total**: 276 MB

**Improvement**: 58% smaller, minimal attack surface!

---

## 🚀 Live Demo

**Demo deployed to kvm151:**

**RHHI Stack:**
- Access: http://192.168.1.151:3001/health
- Status: ✅ Running with database connected

**Let's look at:**
1. Health check endpoint
2. CRUD operations (Create/Read/Update tasks)
3. Container sizes vs traditional images
4. Security scan results

---

## 💡 Key Takeaways

1. **Security First** - Automated gates catch issues before deployment
2. **Not Either/Or** - Use the right tool for the job
3. **Size Matters** - 58% reduction with RHHI enables new use cases
4. **Trade-offs** - Debuggability vs security, support vs flexibility
5. **Multi-arch** - Same code, both AMD64 and ARM64

**The Future**: Mix and match based on workload needs, not one-size-fits-all

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
make ubi    # Build UBI stack
make rhhi   # Build RHHI stack
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
