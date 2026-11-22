#!/usr/bin/env bash
# Admin-only deploy script for the VPS.
# Usage: ./deploy.sh <name> <public_github_https_url> <branch> <port> "<start command>"
# Example: ./deploy.sh my-bot https://github.com/user/repo main 3000 "npm start"
# WARNING: this runs the repo's code on your VPS. Read the repo before deploying it.
set -euo pipefail

NAME="${1:-}"; REPO="${2:-}"; BRANCH="${3:-main}"; PORT="${4:-}"; CMD="${5:-}"

[[ "$NAME" =~ ^[a-z0-9-]{3,30}$ ]] || { echo "Bad name"; exit 1; }
[[ "$REPO" =~ ^https://github\.com/[A-Za-z0-9._-]+/[A-Za-z0-9._-]+(\.git)?/?$ ]] || { echo "Only public https GitHub URL allowed"; exit 1; }
[[ "$BRANCH" =~ ^[A-Za-z0-9._/-]{1,60}$ ]] || { echo "Bad branch"; exit 1; }
[[ "$PORT" =~ ^[0-9]+$ ]] && (( PORT >= 1024 && PORT <= 65535 )) || { echo "Port must be 1024-65535"; exit 1; }
[[ "$CMD" =~ ^[A-Za-z0-9\ _.:/-]{1,100}$ ]] || { echo "Start command has unsafe characters"; exit 1; }

BASE="$HOME/hosting"
DIR="$BASE/$NAME"
mkdir -p "$BASE"

if [ -d "$DIR/.git" ]; then
  git -C "$DIR" fetch --depth 1 origin "$BRANCH"
  git -C "$DIR" reset --hard "origin/$BRANCH"
else
  rm -rf "$DIR"
  git clone --depth 1 --branch "$BRANCH" "$REPO" "$DIR"
fi

cd "$DIR"
if [ -f package.json ]; then
  if [ -f package-lock.json ]; then npm ci --omit=dev; else npm install --omit=dev; fi
fi

pm2 delete "$NAME" >/dev/null 2>&1 || true
PORT="$PORT" pm2 start bash --name "$NAME" --cwd "$DIR" -- -c "$CMD"
pm2 save
echo "Running '$NAME' on port $PORT. Logs: pm2 logs $NAME"
