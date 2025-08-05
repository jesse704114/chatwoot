#!/bin/sh
set -x

rm -rf /app/tmp/pids/server.pid
rm -rf /app/tmp/cache/*

# 檢查 node_modules 是否存在，如果不存在才執行安裝
if [ ! -d "/app/node_modules" ]; then
  pnpm install --force
fi

echo "Ready to run Vite development server."

exec "$@"