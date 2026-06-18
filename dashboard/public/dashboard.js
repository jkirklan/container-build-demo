/**
 * Dashboard JavaScript
 * Connects to SSE endpoint for real-time status updates
 */

const VARIANTS = ['ubi', 'rhhi', 'bootc'];

/**
 * Initialize SSE connection for real-time updates
 */
function initSSE() {
  const eventSource = new EventSource('/events');

  eventSource.onmessage = (event) => {
    try {
      const data = JSON.parse(event.data);
      updateVariantStatus(data);
    } catch (err) {
      console.error('Failed to parse SSE message:', err);
    }
  };

  eventSource.onerror = (err) => {
    console.error('SSE connection error:', err);
    eventSource.close();

    // Retry connection after 5 seconds
    setTimeout(() => {
      console.log('Reconnecting to SSE...');
      initSSE();
    }, 5000);
  };

  console.log('SSE connection established');
}

/**
 * Update UI for a variant's status
 */
function updateVariantStatus(data) {
  const { variant, status, phase, start_time, end_time, error } = data;

  // Update status indicator
  const statusEl = document.querySelector(`#status-${variant} .status-indicator`);
  if (statusEl) {
    statusEl.className = `status-indicator ${status}`;
    statusEl.querySelector('.status-text').textContent = status;
  }

  // Update phase
  const phaseEl = document.getElementById(`phase-${variant}`);
  if (phaseEl) {
    phaseEl.textContent = phase || '-';
  }

  // Update time
  const timeEl = document.getElementById(`time-${variant}`);
  if (timeEl) {
    if (status === 'completed' || status === 'failed') {
      const duration = calculateDuration(start_time, end_time);
      timeEl.textContent = duration ? `Duration: ${duration}` : '-';
    } else if (status === 'running') {
      timeEl.textContent = 'In progress...';
    } else {
      timeEl.textContent = '-';
    }
  }

  // Update error message
  const errorEl = document.getElementById(`error-${variant}`);
  if (errorEl) {
    if (error && error !== 'null') {
      errorEl.textContent = error;
      errorEl.classList.add('visible');
    } else {
      errorEl.classList.remove('visible');
    }
  }

  // Auto-refresh log when status changes
  if (status === 'running' || status === 'completed' || status === 'failed') {
    refreshLog(variant);
  }
}

/**
 * Calculate duration between two ISO timestamps
 */
function calculateDuration(startTime, endTime) {
  if (!startTime || !endTime) return null;

  const start = new Date(startTime);
  const end = new Date(endTime);
  const durationMs = end - start;

  const seconds = Math.floor(durationMs / 1000);
  const minutes = Math.floor(seconds / 60);
  const remainingSeconds = seconds % 60;

  if (minutes > 0) {
    return `${minutes}m ${remainingSeconds}s`;
  }
  return `${seconds}s`;
}

/**
 * Refresh log for a variant
 */
async function refreshLog(variant) {
  try {
    const response = await fetch(`/api/logs/${variant}?lines=100`);
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }

    const data = await response.json();
    const logEl = document.getElementById(`log-${variant}`);

    if (logEl && data.lines) {
      logEl.textContent = data.lines.join('\n');
      // Auto-scroll to bottom
      logEl.scrollTop = logEl.scrollHeight;
    }
  } catch (err) {
    console.error(`Failed to fetch logs for ${variant}:`, err);
  }
}

/**
 * Setup refresh buttons
 */
function setupRefreshButtons() {
  document.querySelectorAll('.refresh-btn').forEach(btn => {
    btn.addEventListener('click', () => {
      const variant = btn.dataset.variant;
      refreshLog(variant);
    });
  });
}

/**
 * Load initial status for all variants
 */
async function loadInitialStatus() {
  try {
    const response = await fetch('/api/variants');
    if (!response.ok) {
      throw new Error(`HTTP ${response.status}`);
    }

    const data = await response.json();
    data.variants.forEach(updateVariantStatus);
  } catch (err) {
    console.error('Failed to load initial status:', err);
  }
}

/**
 * Initialize dashboard
 */
document.addEventListener('DOMContentLoaded', () => {
  console.log('Initializing dashboard...');

  // Load initial status
  loadInitialStatus();

  // Setup SSE connection
  initSSE();

  // Setup refresh buttons
  setupRefreshButtons();

  // Auto-refresh logs every 5 seconds for running builds
  setInterval(() => {
    VARIANTS.forEach(variant => {
      const statusEl = document.querySelector(`#status-${variant} .status-indicator`);
      if (statusEl && statusEl.classList.contains('running')) {
        refreshLog(variant);
      }
    });
  }, 5000);

  console.log('Dashboard initialized');
});
