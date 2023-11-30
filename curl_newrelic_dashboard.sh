#!/bin/bash

NR_API_KEY="NRAK-3JR6X"
ACCOUNT_ID="4151"
NR_GRAPH_URL="https://api.newrelic.com/graphql"
FILENAME="dev/Kubernetes_Dashboard.json"
JSON_DATA=$(cat "$FILENAME")

curl "$NR_GRAPH_URL" \
  -H "API-Key: $NR_API_KEY" \
  -H 'Content-Type: application/json' \
  -d "{\"query\":\"mutation { dashboardCreate(accountId: $ACCOUNT_ID, dashboard: $JSON_DATA) { errors { description type } }}\", \"variables\":{}}"
