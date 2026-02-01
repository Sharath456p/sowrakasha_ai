#!/bin/bash

# Default URL
URL="http://localhost:8000/webhook"

# Payload simulating a Merge Request Open event
PAYLOAD='{
  "object_kind": "merge_request",
  "project": {
    "id": 12345,
    "http_url_to_repo": "https://gitlab.com/sharath-poc/test-mr-project.git"
  },
  "object_attributes": {
    "action": "open",
    "iid": 1,
    "title": "Test MR",
    "source_branch": "feature/test-branch",
    "target_branch": "main"
  }
}'

echo "📡 Sending Mock Webhook to $URL..."
curl -X POST \
     -H "Content-Type: application/json" \
     -H "X-Gitlab-Event: Merge Request Hook" \
     -d "$PAYLOAD" \
     "$URL"

echo ""
