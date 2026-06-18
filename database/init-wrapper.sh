#!/bin/bash
# Wrapper script to run SQL initialization
# Red Hat PostgreSQL container sources .sh files from /usr/share/container-scripts/postgresql/start/

set -e

echo "Running database initialization..."

# Run the SQL initialization script
psql "$POSTGRESQL_DATABASE" < /usr/share/container-scripts/postgresql/start/init.sql

echo "✅ Database initialization complete"
