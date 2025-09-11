#!/bin/sh
set -x
set -e

rm -rf /app/tmp/pids/server.pid

# 確保 Bundler 使用鏡像中的 /gems 路徑（在 chatwoot:development 映像中已安裝）
export BUNDLE_PATH="/gems"
export BUNDLE_APP_CONFIG="/gems/config"

gem install bundler -v '2.5.11'

# 如容器掛載覆蓋導致缺 gem，這裡做一次檢查與安裝
if ! bundle check; then
  echo "Gems missing, running bundle install to sync dependencies..."
  bundle install -j 4 -r 3 || bundle install
fi

# 檢查 node_modules 是否存在，如果不存在才執行安裝
if [ ! -d "/app/node_modules" ]; then
  echo "node_modules not found, reinstalling dependencies and clearing cache."
  pnpm install --force
  rm -rf /app/tmp/cache/*
fi

echo "Ready to run Vite development server."

exec "$@"