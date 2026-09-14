#!/bin/bash
# Simple concurrent load test against the frontend service.
# Usage: ./load-test.sh <target-url> <concurrent-users> <requests-per-user>

TARGET_URL=${1:-http://frontend-service:8080}
CONCURRENT_USERS=${2:-10}
REQUESTS_PER_USER=${3:-20}

echo "Load testing $TARGET_URL"
echo "Concurrent users: $CONCURRENT_USERS"
echo "Requests per user: $REQUESTS_PER_USER"

run_user() {
  local user_id=$1
  local success=0
  local failure=0
  for i in $(seq 1 "$REQUESTS_PER_USER"); do
    if curl -s -o /dev/null -w "%{http_code}" "$TARGET_URL" | grep -q "200"; then
      success=$((success + 1))
    else
      failure=$((failure + 1))
    fi
  done
  echo "User $user_id: $success succeeded, $failure failed"
}

START_TIME=$(date +%s)

for u in $(seq 1 "$CONCURRENT_USERS"); do
  run_user "$u" &
done

wait

END_TIME=$(date +%s)
TOTAL_TIME=$((END_TIME - START_TIME))
TOTAL_REQUESTS=$((CONCURRENT_USERS * REQUESTS_PER_USER))

echo "-----------------------------------------"
echo "Total requests sent: $TOTAL_REQUESTS"
echo "Total time elapsed: ${TOTAL_TIME}s"
echo "Approximate throughput: $((TOTAL_REQUESTS / (TOTAL_TIME > 0 ? TOTAL_TIME : 1))) req/s"
