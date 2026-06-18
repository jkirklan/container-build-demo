#!/usr/bin/env node

/**
 * Live Demo Dashboard Server
 *
 * Serves a real-time dashboard showing build/scan/deploy progress
 * for all three RHEL deployment tracks:
 * - UBI (container-native)
 * - RHHI (distroless)
 * - bootc (image mode)
 *
 * Uses Server-Sent Events (SSE) for real-time updates.
 */

const express = require('express');
const fs = require('fs');
const path = require('path');
const { EventEmitter } = require('events');

const app = express();
const PORT = process.env.PORT || 8888;

const STATUS_DIR = path.join(__dirname, 'status');
const LOG_DIR = path.join(__dirname, '../logs');

// Event emitter for SSE
const statusEmitter = new EventEmitter();

// Ensure directories exist
[STATUS_DIR, LOG_DIR].forEach(dir => {
  if (!fs.existsSync(dir)) {
    fs.mkdirSync(dir, { recursive: true });
  }
});

// Serve static files
app.use(express.static(path.join(__dirname, 'public')));

/**
 * SSE endpoint for real-time status updates
 * Clients connect to this and receive status changes
 */
app.get('/events', (req, res) => {
  res.setHeader('Content-Type', 'text/event-stream');
  res.setHeader('Cache-Control', 'no-cache');
  res.setHeader('Connection', 'keep-alive');

  // Send initial status for all variants
  const variants = ['ubi', 'rhhi', 'bootc'];
  variants.forEach(variant => {
    const status = readStatus(variant);
    res.write(`data: ${JSON.stringify({ variant, ...status })}\n\n`);
  });

  // Listen for updates
  const listener = (data) => {
    res.write(`data: ${JSON.stringify(data)}\n\n`);
  };

  statusEmitter.on('status-update', listener);

  // Cleanup on client disconnect
  req.on('close', () => {
    statusEmitter.off('status-update', listener);
    res.end();
  });
});

/**
 * API endpoint to get current status for a variant
 */
app.get('/api/status/:variant', (req, res) => {
  const { variant } = req.params;
  const status = readStatus(variant);

  if (!status) {
    return res.status(404).json({ error: 'Variant not found' });
  }

  res.json({ variant, ...status });
});

/**
 * API endpoint to get log tail for a variant
 */
app.get('/api/logs/:variant', (req, res) => {
  const { variant } = req.params;
  const { lines = 50 } = req.query;

  const logFiles = {
    ubi: path.join(LOG_DIR, 'build-ubi.log'),
    rhhi: path.join(LOG_DIR, 'build-rhhi.log'),
    bootc: path.join(LOG_DIR, 'build-bootc.log')
  };

  const logFile = logFiles[variant];
  if (!logFile || !fs.existsSync(logFile)) {
    return res.status(404).json({ error: 'Log file not found' });
  }

  try {
    const content = fs.readFileSync(logFile, 'utf8');
    const logLines = content.split('\n').slice(-parseInt(lines, 10));
    res.json({ variant, lines: logLines });
  } catch (err) {
    res.status(500).json({ error: err.message });
  }
});

/**
 * API endpoint to list all variants
 */
app.get('/api/variants', (req, res) => {
  const variants = ['ubi', 'rhhi', 'bootc'].map(variant => ({
    variant,
    ...readStatus(variant)
  }));
  res.json({ variants });
});

/**
 * Read status JSON file for a variant
 */
function readStatus(variant) {
  const statusFile = path.join(STATUS_DIR, `${variant}.json`);

  if (!fs.existsSync(statusFile)) {
    return {
      status: 'pending',
      phase: 'init',
      start_time: null,
      end_time: null,
      error: null
    };
  }

  try {
    return JSON.parse(fs.readFileSync(statusFile, 'utf8'));
  } catch (err) {
    console.error(`Error reading status for ${variant}:`, err);
    return {
      status: 'error',
      phase: 'unknown',
      start_time: null,
      end_time: null,
      error: `Failed to read status: ${err.message}`
    };
  }
}

/**
 * Watch status directory for changes and emit events
 */
function watchStatusFiles() {
  const variants = ['ubi', 'rhhi', 'bootc'];

  variants.forEach(variant => {
    const statusFile = path.join(STATUS_DIR, `${variant}.json`);

    // Watch for file changes
    fs.watch(statusFile, (eventType) => {
      if (eventType === 'change') {
        const status = readStatus(variant);
        statusEmitter.emit('status-update', { variant, ...status });
      }
    });

    console.log(`Watching status file: ${statusFile}`);
  });
}

// Start server
app.listen(PORT, () => {
  console.log('');
  console.log('=========================================');
  console.log('  Demo Dashboard Server');
  console.log('=========================================');
  console.log('');
  console.log(`Dashboard: http://localhost:${PORT}`);
  console.log(`SSE events: http://localhost:${PORT}/events`);
  console.log(`API: http://localhost:${PORT}/api/variants`);
  console.log('');
  console.log('Press Ctrl+C to stop');
  console.log('');

  // Start watching status files
  watchStatusFiles();
});

// Graceful shutdown
process.on('SIGINT', () => {
  console.log('\nShutting down dashboard server...');
  process.exit(0);
});
