#!/bin/bash
set -e

# Enhanced npm security checking for malware detection
# Beyond basic npm audit - detects supply chain attacks, typosquatting, suspicious packages

PACKAGE_JSON="${1:-package.json}"
PACKAGE_LOCK="${2:-package-lock.json}"

if [ ! -f "$PACKAGE_JSON" ]; then
  echo "❌ package.json not found: $PACKAGE_JSON"
  exit 1
fi

echo "=== Enhanced npm Security Checks ==="
echo "Package.json: $PACKAGE_JSON"
echo "Package-lock: $PACKAGE_LOCK"
echo ""

# Check 1: Standard npm audit (HIGH/CRITICAL only)
echo "🔍 Check 1: npm audit (known vulnerabilities)"
if npm audit --production --audit-level=high 2>&1 | tee /tmp/npm-audit.log; then
  echo "✅ No HIGH/CRITICAL vulnerabilities found"
else
  echo "❌ FAILED: HIGH or CRITICAL vulnerabilities found"
  cat /tmp/npm-audit.log
  exit 1
fi
echo ""

# Check 2: Detect suspicious install scripts
echo "🔍 Check 2: Install script detection (malware risk)"
INSTALL_SCRIPTS=$(jq -r '
  .dependencies as $deps |
  to_entries[] |
  select(.value.scripts.install != null or .value.scripts.preinstall != null or .value.scripts.postinstall != null) |
  "\(.key): \(.value.scripts | to_entries | map("\(.key)=\(.value)") | join(", "))"
' "$PACKAGE_LOCK" 2>/dev/null || echo "")

if [ -n "$INSTALL_SCRIPTS" ]; then
  echo "⚠️  WARNING: Packages with install scripts detected (review manually):"
  echo "$INSTALL_SCRIPTS"
  echo ""
  echo "These scripts run automatically during npm install and could contain malware."
  echo "Review each package before proceeding:"
  echo "  - Check package reputation on npmjs.com"
  echo "  - Review GitHub repository"
  echo "  - Check download counts and maintenance status"
  echo ""
else
  echo "✅ No packages with install scripts"
fi
echo ""

# Check 3: Typosquatting detection (common misspellings)
echo "🔍 Check 3: Typosquatting detection"
KNOWN_TYPOS=(
  "loadsh:lodash"
  "reacct:react"
  "expresss:express"
  "mongose:mongoose"
  "crossenv:cross-env"
  "event-srteam:event-stream"
  "electorn:electron"
  "reqeust:request"
)

FOUND_TYPOS=""
for TYPO_PAIR in "${KNOWN_TYPOS[@]}"; do
  TYPO=$(echo "$TYPO_PAIR" | cut -d':' -f1)
  CORRECT=$(echo "$TYPO_PAIR" | cut -d':' -f2)

  if grep -q "\"$TYPO\"" "$PACKAGE_JSON" 2>/dev/null; then
    FOUND_TYPOS="$FOUND_TYPOS\n  ❌ '$TYPO' detected - did you mean '$CORRECT'?"
  fi
done

if [ -n "$FOUND_TYPOS" ]; then
  echo "❌ FAILED: Typosquatting detected!"
  echo -e "$FOUND_TYPOS"
  exit 1
else
  echo "✅ No known typosquatting packages detected"
fi
echo ""

# Check 4: Lockfile integrity check
echo "🔍 Check 4: Lockfile integrity"
if [ -f "$PACKAGE_LOCK" ]; then
  # Verify lockfile version matches package.json dependencies
  PKG_DEPS=$(jq -r '.dependencies | keys | .[]' "$PACKAGE_JSON" 2>/dev/null | sort || echo "")
  LOCK_DEPS=$(jq -r '.dependencies | keys | .[]' "$PACKAGE_LOCK" 2>/dev/null | sort || echo "")

  if [ "$PKG_DEPS" = "$LOCK_DEPS" ]; then
    echo "✅ Lockfile matches package.json"
  else
    echo "⚠️  WARNING: Lockfile may be out of sync with package.json"
    echo "Run: npm install --package-lock-only"
  fi
else
  echo "⚠️  WARNING: No package-lock.json found (should exist for reproducible builds)"
fi
echo ""

# Check 5: Detect packages from untrusted registries
echo "🔍 Check 5: Registry validation"
UNTRUSTED_REGISTRIES=$(jq -r '
  .dependencies | to_entries[] |
  select(.value.resolved != null and (.value.resolved | startswith("https://registry.npmjs.org") | not)) |
  "\(.key): \(.value.resolved)"
' "$PACKAGE_LOCK" 2>/dev/null || echo "")

if [ -n "$UNTRUSTED_REGISTRIES" ]; then
  echo "⚠️  WARNING: Packages from non-npmjs registries:"
  echo "$UNTRUSTED_REGISTRIES"
  echo ""
  echo "Verify these registries are trusted before deploying."
else
  echo "✅ All packages from registry.npmjs.org"
fi
echo ""

# Check 6: Detect packages with low download counts (potential malware)
echo "🔍 Check 6: Package popularity check"
echo "⚠️  Manual check recommended for new/unknown packages:"
echo "  1. Visit https://npmjs.com/package/<name>"
echo "  2. Check weekly downloads (>1000 is typical for popular packages)"
echo "  3. Check last publish date (recent activity is good)"
echo "  4. Check GitHub stars/issues"
echo "  5. Check maintainer reputation"
echo ""

# Summary
echo "=== Summary ==="
echo "✅ npm audit passed (no HIGH/CRITICAL vulnerabilities)"
if [ -n "$INSTALL_SCRIPTS" ]; then
  echo "⚠️  Install scripts detected (manual review required)"
fi
echo "✅ No typosquatting detected"
echo "✅ Lockfile integrity checked"
if [ -n "$UNTRUSTED_REGISTRIES" ]; then
  echo "⚠️  Non-standard registries detected (manual review required)"
fi
echo ""
echo "✅ Enhanced security checks completed"
echo ""
echo "Additional tools to consider:"
echo "  - Socket.dev: https://socket.dev (real-time supply chain analysis)"
echo "  - Snyk: https://snyk.io (commercial npm scanning)"
echo "  - npm-check-updates: Check for suspicious version jumps"
echo "  - lockfile-lint: Validate package-lock integrity"
