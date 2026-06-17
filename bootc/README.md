# Bootable Container Demo

This directory contains a **bootable container image** variant of the task tracker demo - a fundamentally different deployment paradigm from the UBI and RHHI application containers.

## What is a bootable container?

A bootable container is a **full operating system image** packaged as a container. Unlike application containers (UBI/RHHI), which run on top of an existing OS, bootable containers **ARE** the OS.

**Key differences:**

| Feature | Application Container | Bootable Container |
|---------|----------------------|-------------------|
| Contains | Just the application | Full OS + application |
| Runs on | Existing host OS | Bare metal or VM |
| Size | 128-401 MB | 1-2 GB+ |
| Boot | Podman/Docker start | System boot (grub/systemd) |
| Updates | Container pull/restart | OS-level upgrade (bootc) |
| Isolation | Process/namespace | Full system |

## Architecture

```
┌─────────────────────────────────────┐
│   Bootable Container Image          │
├─────────────────────────────────────┤
│ • CentOS Stream 9 base OS           │
│ • PostgreSQL server                 │
│ • Node.js runtime                   │
│ • Task tracker app (/opt/demo-app)  │
│ • Systemd services (postgres, app)  │
│ • Network stack, kernel, init       │
└─────────────────────────────────────┘
          ↓ bootc install/switch
┌─────────────────────────────────────┐
│   Physical/VM System                │
│   (boots directly into this image)  │
└─────────────────────────────────────┘
```

## Build

```bash
# Build bootable image
cd demo/bootc
podman build --platform linux/amd64 -t demo-bootc:latest -f Containerfile ..

# Note: Build context is parent directory (..) to access webapp/
```

## Deployment Options

### Option 1: bootc install (new system)

```bash
# Install to disk (replaces entire OS)
bootc install to-disk --image demo-bootc:latest /dev/sda
```

### Option 2: bootc switch (existing bootc system)

```bash
# Switch running system to new image
bootc switch ghcr.io/jkirklan/demo-bootc:latest
systemctl reboot
```

### Option 3: bootc upgrade (update existing)

```bash
# Upgrade to newer version of same image
bootc upgrade
systemctl reboot
```

### Option 4: Run as VM (libvirt/QEMU)

```bash
# Convert to qcow2 disk image
podman run --rm --privileged \
  -v ./output:/output \
  quay.io/centos-bootc/bootc-image-builder:latest \
  --type qcow2 \
  demo-bootc:latest

# Boot with QEMU/libvirt
virt-install --import --disk ./output/disk.qcow2 --os-variant rhel9.0
```

## Use Cases

**When to use bootable containers:**

✅ **Immutable infrastructure** - OS + app versioned together
✅ **Edge deployments** - Single image for remote systems
✅ **Appliances** - Purpose-built systems (kiosks, IoT)
✅ **Reproducible systems** - Exact OS+app state in image
✅ **Atomic updates** - Full system upgrade with rollback

**When NOT to use:**

❌ **Multi-tenant** - Each app needs its own OS
❌ **Microservices** - Too heavyweight per service
❌ **Development** - Slow iteration (full OS rebuild)
❌ **Shared infrastructure** - Can't run multiple apps

## Comparison with UBI/RHHI

| Aspect | UBI/RHHI Containers | Bootable Container |
|--------|--------------------|--------------------|
| **Deployment** | Podman quadlet on existing OS | Full OS boot |
| **Update** | Pull new image, restart container | bootc upgrade + reboot |
| **Size** | 128-645 MB | 1-2 GB+ |
| **Startup** | Seconds | Minutes (OS boot) |
| **Isolation** | Process/namespace | Full system |
| **Host OS** | Required (RHEL, Fedora, etc.) | Not needed (IS the OS) |
| **Multi-app** | Yes (many containers) | No (one app per OS) |
| **Use case** | General applications | Appliances, edge, immutable infra |

## What's Inside

The bootable image includes:

- **Base OS**: CentOS Stream 9 (bootc-compatible)
- **Database**: PostgreSQL 15 with automatic initialization
- **Runtime**: Node.js 20
- **Application**: Task tracker in `/opt/demo-app`
- **Services**: Systemd units for postgres + webapp
- **Network**: Full network stack, firewall, SSH

## Testing

**Local testing** (requires bootc-compatible system):

```bash
# Build
podman build -t demo-bootc:latest .

# Test in VM
bootc-image-builder --type qcow2 demo-bootc:latest
qemu-system-x86_64 -m 2048 -drive file=output/disk.qcow2
```

**Access:**
- SSH: Port 22 (root login with key)
- Web app: http://[VM-IP]:3000
- Database: localhost:5432 (internal only)

## Security Considerations

**Pros:**
- ✅ Immutable OS (read-only root)
- ✅ Atomic updates with rollback
- ✅ Full OS security updates via bootc
- ✅ No package manager in running system

**Cons:**
- ⚠️ Larger attack surface (full OS, not minimal)
- ⚠️ Requires reboot for updates
- ⚠️ Debugging harder (no shell in minimal variants)

## Production Readiness

**This is a DEMO.** For production bootable containers:

- [ ] Use secrets management (not hardcoded passwords)
- [ ] Configure firewall rules
- [ ] Set up SSH keys (disable password auth)
- [ ] Harden PostgreSQL (network exposure, auth)
- [ ] Add monitoring/logging
- [ ] Configure backups
- [ ] Test rollback procedures
- [ ] Document disaster recovery

## References

- **bootc project**: https://github.com/containers/bootc
- **CentOS bootc**: https://gitlab.com/CentOS/cloud/bootc
- **Image Mode RHEL**: https://developers.redhat.com/articles/rhel-image-mode
- **bootc-image-builder**: https://github.com/osbuild/bootc-image-builder

## Why Include This Variant?

This demonstrates a **third deployment paradigm**:

1. **UBI** - Traditional container, enterprise support, full tooling
2. **RHHI** - Distroless container, minimal attack surface, no shell
3. **Bootc** - Bootable OS image, immutable infrastructure, appliance model

Each has different trade-offs in security, manageability, and use cases. The presentation can now compare all three approaches!
