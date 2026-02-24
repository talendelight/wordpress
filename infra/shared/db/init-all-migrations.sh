#!/bin/bash
# Initialize WordPress database with all migrations
# This script applies all SQL migrations in order

echo "=== WordPress Database Initialization ==="
echo "Applying all SQL migrations from /docker-entrypoint-initdb.d/..."

cd /docker-entrypoint-initdb.d/

for sql_file in $(ls *.sql | sort); do
    echo "Applying: $sql_file"
    mariadb -u root -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE" < "$sql_file"
    if [ $? -eq 0 ]; then
        echo "✓ $sql_file applied successfully"
    else
        echo "✗ $sql_file failed"
        exit 1
    fi
done

echo "=== Database initialization complete ==="
mariadb -u root -p"$MYSQL_ROOT_PASSWORD" "$MYSQL_DATABASE" -e "SELECT COUNT(*) as total_tables FROM information_schema.tables WHERE table_schema = '$MYSQL_DATABASE'"

echo ""
echo "Next steps:"
echo "  1. Run: pwsh infra/shared/scripts/wp-action.ps1 restore-pages"
echo "  2. Run: pwsh infra/shared/scripts/wp-action.ps1 restore-menus"
