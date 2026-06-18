#!/bin/bash
set -e

VARIANT="${1:-ubi}"

if [ "$VARIANT" = "ubi" ]; then
  PORT=3001
  NAME="UBI"
elif [ "$VARIANT" = "rhhi" ]; then
  PORT=3002
  NAME="RHHI"
else
  echo "❌ Invalid variant: $VARIANT"
  echo "Usage: $0 [ubi|rhhi]"
  exit 1
fi

BASE_URL="http://localhost:$PORT"

echo "=== Testing Demo ($NAME) ==="
echo "Base URL: $BASE_URL"
echo ""

# Test 1: Health check
echo "🏥 Test 1: Health check..."
HEALTH=$(curl -s "$BASE_URL/health")
if echo "$HEALTH" | grep -q '"status":"ok"'; then
  echo "✅ Health check passed"
  echo "   Response: $HEALTH"
else
  echo "❌ Health check failed"
  echo "   Response: $HEALTH"
  exit 1
fi

echo ""

# Test 2: List tasks
echo "📋 Test 2: List tasks..."
TASKS=$(curl -s "$BASE_URL/api/tasks")
if echo "$TASKS" | grep -q '"success":true'; then
  echo "✅ List tasks passed"
  TASK_COUNT=$(echo "$TASKS" | jq '.tasks | length')
  echo "   Task count: $TASK_COUNT"
else
  echo "❌ List tasks failed"
  echo "   Response: $TASKS"
  exit 1
fi

echo ""

# Test 3: Create task
echo "➕ Test 3: Create task..."
CREATE_RESPONSE=$(curl -s -X POST "$BASE_URL/api/tasks" \
  -H "Content-Type: application/json" \
  -d '{"title":"Test Task from Smoke Tests","description":"Automated test task"}')

if echo "$CREATE_RESPONSE" | grep -q '"success":true'; then
  echo "✅ Create task passed"
  TASK_ID=$(echo "$CREATE_RESPONSE" | jq -r '.task.id')
  echo "   Created task ID: $TASK_ID"
else
  echo "❌ Create task failed"
  echo "   Response: $CREATE_RESPONSE"
  exit 1
fi

echo ""

# Test 4: Update task
echo "✏️  Test 4: Update task..."
UPDATE_RESPONSE=$(curl -s -X PUT "$BASE_URL/api/tasks/$TASK_ID" \
  -H "Content-Type: application/json" \
  -d '{"completed":true}')

if echo "$UPDATE_RESPONSE" | grep -q '"success":true'; then
  echo "✅ Update task passed"
  COMPLETED=$(echo "$UPDATE_RESPONSE" | jq -r '.task.completed')
  echo "   Task marked as completed: $COMPLETED"
else
  echo "❌ Update task failed"
  echo "   Response: $UPDATE_RESPONSE"
  exit 1
fi

echo ""

# Test 5: Delete task
echo "🗑️  Test 5: Delete task..."
DELETE_RESPONSE=$(curl -s -X DELETE "$BASE_URL/api/tasks/$TASK_ID")

if echo "$DELETE_RESPONSE" | grep -q '"success":true'; then
  echo "✅ Delete task passed"
else
  echo "❌ Delete task failed"
  echo "   Response: $DELETE_RESPONSE"
  exit 1
fi

echo ""
echo "✅ All tests passed for $NAME demo!"
echo ""
echo "Summary:"
echo "  ✅ Health check"
echo "  ✅ List tasks"
echo "  ✅ Create task"
echo "  ✅ Update task"
echo "  ✅ Delete task"
