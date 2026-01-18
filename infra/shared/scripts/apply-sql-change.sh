#!/bin/bash
# Bash script to apply a SQL file to a MySQL/MariaDB database (production/CI/CD)
# Usage: ./apply-sql-change.sh <sql-file-path> <db-host> <db-port> <db-user> <db-password> <db-name>

set -e

SQL_FILE="$1"
DB_HOST="$2"
DB_PORT="$3"
DB_USER="$4"
DB_PASSWORD="$5"
DB_NAME="$6"

if [ -z "$SQL_FILE" ] || [ ! -f "$SQL_FILE" ]; then
  echo "SQL file not found: $SQL_FILE"
  exit 1
fi

if [ -z "$DB_HOST" ] || [ -z "$DB_PORT" ] || [ -z "$DB_USER" ] || [ -z "$DB_PASSWORD" ] || [ -z "$DB_NAME" ]; then
  echo "Usage: $0 <sql-file-path> <db-host> <db-port> <db-user> <db-password> <db-name>"
  exit 1
fi

echo "Applying SQL file: $SQL_FILE to database $DB_NAME on $DB_HOST:$DB_PORT..."

mysql -h "$DB_HOST" -P "$DB_PORT" -u "$DB_USER" -p"$DB_PASSWORD" "$DB_NAME" < "$SQL_FILE"

if [ $? -eq 0 ]; then
  echo "SQL applied successfully."
else
  echo "Failed to apply SQL."
  exit 1
fi
