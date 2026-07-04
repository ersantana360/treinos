#!/usr/bin/env bash
# Publish treinos: commit + push to GitHub + deploy to Cloudflare.
# Usage: ./scripts/publish.sh "optional commit message"
set -euo pipefail
cd "$(dirname "$0")/.."

msg="${1:-update training}"

git add -A
if git diff --cached --quiet; then
  echo "nothing to commit — deploying current state"
else
  git commit -m "$msg"
  git push origin main
fi

wrangler deploy
echo "✓ published — https://treinos.neves-erick.workers.dev/me"
