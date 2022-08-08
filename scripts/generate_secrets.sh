#!/usr/bin/env bash

cat >charts/backstage/values-secrets.yaml<<EOL
secrets:
  AZURE_TOKEN: ${AZURE_TOKEN:-}
  GITHUB_TOKEN: ${AUTH_GITHUB_TOKEN:-}
  AUTH_GITHUB_CLIENT_ID: ${AUTH_GITHUB_CLIENT_ID:-}
  AUTH_GITHUB_CLIENT_SECRET: ${AUTH_GITHUB_CLIENT_SECRET:-}
EOL

exit 0
