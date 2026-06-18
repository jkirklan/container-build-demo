# Live Demo Dashboard

Real-time web dashboard showing build/scan progress for all three RHEL deployment tracks.

## Overview

This dashboard provides **live visibility** into parallel container builds during presentations or demos. It displays real-time progress for:

1. **UBI** - RHEL Universal Base Images (enterprise containers)
2. **RHHI** - Red Hat Hummingbird Images (distroless containers)
3. **bootc** - Image Mode / Bootable Containers (immutable OS)

## Architecture

```
┌──────────────┐          ┌──────────────┐          ┌──────────────┐
│ Build Script │          │ Express      │          │   Browser    │
│ (parallel)   │ ────────>│ Server       │<─────────│  Dashboard   │
│              │  writes  │ (SSE)        │  SSE     │   (HTML/JS)  │
└──────────────┘  status  └──────────────┘          └──────────────┘
                  JSON
                  files
```

**Technology:**
- **Backend**: Express.js (Node.js 18+)
- **Real-time**: Server-Sent Events (SSE)
- **Status tracking**: JSON files in `status/` directory
- **Logs**: Build logs in `../logs/` directory
- **Frontend**: Vanilla HTML/CSS/JavaScript (no frameworks)

## Quick Start

### From Makefile (easiest)

```bash
# Start dashboard only
make dashboard

# Start dashboard + run parallel builds
make demo
```

### Manual Start

```bash
cd dashboard

# Install dependencies (first time only)
npm install

# Start server
./start-dashboard.sh

# Or use npm
npm start
```

**Dashboard URL:** http://localhost:8888

## How It Works

### Status Tracking

Each variant (ubi/rhhi/bootc) has a JSON status file:

```bash
dashboard/status/ubi.json
dashboard/status/rhhi.json
dashboard/status/bootc.json
```

**Status file format:**

```json
{
  "variant": "ubi",
  "status": "running",
  "phase": "build",
  "start_time": "2026-06-18T14:30:00Z",
  "end_time": null,
  "error": null
}
```

**Status values:**
- `pending` - Not started
- `running` - Build in progress
- `completed` - Success
- `failed` - Error occurred

**Phase values:**
- `init` - Initializing
- `build` - Building images
- `scan` - Security scanning

### Server-Sent Events (SSE)

The dashboard uses SSE for real-time updates:

```javascript
const eventSource = new EventSource('/events');

eventSource.onmessage = (event) => {
  const data = JSON.parse(event.data);
  updateUI(data);
};
```

**Why SSE instead of WebSocket?**
- ✅ Simpler (one-way server → client)
- ✅ Auto-reconnect on disconnect
- ✅ HTTP/1.1 compatible (no upgrade needed)
- ✅ Built-in event stream format
- ❌ WebSocket is overkill for status updates

### Log Streaming

Logs are streamed from build output files:

```
demo/logs/build-ubi.log
demo/logs/build-rhhi.log
demo/logs/build-bootc.log
```

The dashboard auto-refreshes logs every 5 seconds for running builds.

## API Endpoints

### GET /events

SSE endpoint for real-time status updates.

**Response:** Stream of JSON events

```
data: {"variant":"ubi","status":"running","phase":"build",...}

data: {"variant":"rhhi","status":"completed","phase":"scan",...}
```

### GET /api/status/:variant

Get current status for a specific variant.

**Parameters:**
- `variant` - `ubi`, `rhhi`, or `bootc`

**Response:**

```json
{
  "variant": "ubi",
  "status": "running",
  "phase": "build",
  "start_time": "2026-06-18T14:30:00Z",
  "end_time": null,
  "error": null
}
```

### GET /api/logs/:variant

Get build log tail for a variant.

**Parameters:**
- `variant` - `ubi`, `rhhi`, or `bootc`
- `lines` - Number of lines to return (default: 50)

**Response:**

```json
{
  "variant": "ubi",
  "lines": [
    "=== Building UBI images ===",
    "Sending build context to Podman...",
    "STEP 1/10: FROM registry.access.redhat.com/ubi9/nodejs-20:latest AS builder"
  ]
}
```

### GET /api/variants

Get status for all variants.

**Response:**

```json
{
  "variants": [
    {"variant": "ubi", "status": "completed", ...},
    {"variant": "rhhi", "status": "running", ...},
    {"variant": "bootc", "status": "pending", ...}
  ]
}
```

## Usage in Presentations

### Scenario 1: Live Build Demo

1. Start dashboard before presentation:
   ```bash
   make dashboard
   ```

2. Open http://localhost:8888 in browser

3. During presentation, trigger parallel builds:
   ```bash
   make build-parallel
   ```

4. Dashboard auto-updates in real-time
   - Audience sees all three tracks building simultaneously
   - Progress bars, phases, and logs update live
   - Completed builds show green status

### Scenario 2: Pre-Built Demo

1. Build everything first (no live builds):
   ```bash
   make build-all
   ```

2. Start dashboard to show results:
   ```bash
   make dashboard
   ```

3. Dashboard shows completed status for all variants

### Scenario 3: Screen Recording

```bash
# Start dashboard
make dashboard

# In another terminal, run parallel builds
make build-parallel

# Record browser window showing live dashboard
# (Use OBS, QuickTime, etc.)
```

## Configuration

### Port

Default: `8888`

Override via environment variable:

```bash
PORT=3000 npm start
```

### Log Lines

Default: 50 lines per log request

Modify in API call:

```bash
curl http://localhost:8888/api/logs/ubi?lines=100
```

## Development

### Watch Mode

```bash
npm run dev
```

Uses `nodemon` to auto-restart on file changes.

### File Structure

```
dashboard/
├── server.js             # Express server + SSE
├── package.json          # Dependencies
├── start-dashboard.sh    # Startup script
├── README.md             # This file
├── public/               # Static files
│   ├── index.html        # Dashboard UI
│   ├── style.css         # Styling
│   └── dashboard.js      # Client-side logic
├── status/               # Status JSON files (gitignored)
│   ├── ubi.json
│   ├── rhhi.json
│   └── bootc.json
└── node_modules/         # NPM dependencies (gitignored)
```

## Troubleshooting

### "Port already in use"

```bash
# Find process using port 8888
lsof -i :8888

# Kill it
kill $(lsof -t -i:8888)

# Or use different port
PORT=9999 npm start
```

### "Status files not found"

Status files are created by `build-demo-parallel.sh`. If missing:

```bash
mkdir -p dashboard/status
```

### "Logs not updating"

Check that build scripts are writing to `logs/`:

```bash
ls -la logs/
```

### SSE connection drops

SSE auto-reconnects after 5 seconds. Check console logs:

```javascript
// In browser console
eventSource.readyState
// 0 = CONNECTING, 1 = OPEN, 2 = CLOSED
```

## Performance

**Resource usage:**
- CPU: Minimal (~1% when idle, ~5% during SSE updates)
- Memory: ~30MB Node.js process
- Network: SSE streams are lightweight (a few KB/s)
- Concurrent clients: Tested with 10+ browsers simultaneously

**Scaling:**
- For 100+ viewers, consider adding a reverse proxy (nginx)
- Status JSON files are tiny (<1KB each)
- Log tailing is on-demand (not preloaded)

## Security Considerations

**Dashboard is for LOCAL demos only.**

- ❌ Not hardened for production
- ❌ No authentication
- ❌ No HTTPS
- ❌ Log files may contain sensitive data

**For public demos:**
- Use screen recording instead of live dashboard
- Or deploy behind VPN/auth proxy

## Credits

Built for the RHEL container build pipeline demo to showcase:
- Real-time build progress
- Three deployment paradigms in parallel
- Security-first CI/CD pipelines

Technology stack chosen for **simplicity and reliability** during live presentations.
