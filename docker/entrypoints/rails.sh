#!/bin/sh

set -x

# Remove a potentially pre-existing server.pid for Rails.
rm -rf /app/tmp/pids/server.pid
rm -rf /app/tmp/cache/*

echo "Waiting for postgres to become ready...."

# Let DATABASE_URL env take presedence over individual connection params.
# This is done to avoid printing the DATABASE_URL in the logs
$(docker/entrypoints/helpers/pg_database_url.rb)
PG_READY="pg_isready -h $POSTGRES_HOST -p $POSTGRES_PORT -U $POSTGRES_USERNAME"

until $PG_READY
do
  sleep 2;
done

echo "Database ready to accept connections."

#install missing gems for local dev as we are using base image compiled for production
bundle install

BUNDLE="bundle check"

until $BUNDLE
do
  sleep 2;
done

# Database initialization and migration
echo "Checking database status..."

# Check if database exists
DB_EXISTS=$(bundle exec rails runner "puts ActiveRecord::Base.connection.database_exists?" 2>/dev/null || echo "false")

if [ "$DB_EXISTS" = "false" ]; then
  echo "Database does not exist. Creating database..."
  bundle exec rails db:create

  echo "Running database migrations..."
  bundle exec rails db:migrate

  echo "Loading database seeds..."
  bundle exec rails db:seed

  # Check for pending migrations
  PENDING_MIGRATIONS=$(bundle exec rails db:migrate:status | grep "down" | wc -l)

  if [ "$PENDING_MIGRATIONS" -gt 0 ]; then
    echo "Found $PENDING_MIGRATIONS pending migrations. Running migrations..."
    bundle exec rails db:migrate
    echo "Migrations completed."
  else
    echo "No pending migrations found."
  fi
fi

echo "Database setup completed. Starting application..."

# Execute the main process of the container
exec "$@"