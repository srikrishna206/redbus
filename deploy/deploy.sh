#!/usr/bin/env bash
# deploy/deploy.sh
# Usage: deploy.sh user@host /path/to/deploy
REMOTE="$1"
REMOTE_PATH="${2:-/home/deploy}"
COMPOSE_FILE="${3:-deploy/docker-compose.yml}"

# push compose file and start containers
scp -r $COMPOSE_FILE $REMOTE:$REMOTE_PATH/docker-compose.yml
ssh $REMOTE "
  mkdir -p $REMOTE_PATH/back-end-redbus || true
  docker compose -f $REMOTE_PATH/docker-compose.yml pull || true
  docker compose -f $REMOTE_PATH/docker-compose.yml up -d --remove-orphans
"
