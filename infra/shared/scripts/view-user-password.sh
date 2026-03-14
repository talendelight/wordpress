#!/usr/bin/env bash
# Local Development Password Viewer/Resetter
# Usage: ./infra/shared/scripts/view-user-password.sh <email>
#
# This script is for LOCAL DEVELOPMENT ONLY
# It allows you to:
# 1. See recently created users from saved requests
# 2. Reset a user's password and display the new password
#
# Production: Users receive passwords via email, no need for this script

if [ -z "$1" ]; then
    echo "Usage: $0 <email>"
    echo ""
    echo "Example: $0 john@example.com"
    echo ""
    echo "This will reset the user's password and display the new password."
    exit 1
fi

EMAIL="$1"

# Check if running inside container
if [ -f /.dockerenv ] || [ -f /run/.containerenv ]; then
    # Inside container
    WP_CLI="wp"
else
    # Outside container - use podman exec
    WP_CLI="podman exec wp wp"
fi

# Check if user exists
USER_EXISTS=$($WP_CLI user get "$EMAIL" --field=ID --allow-root --skip-plugins 2>/dev/null)

if [ -z "$USER_EXISTS" ]; then
    echo "❌ User not found: $EMAIL"
    echo ""
    echo "Recently saved users:"
    $WP_CLI user list --role=td_candidate,td_employer,td_scout --format=table --allow-root --skip-plugins
    exit 1
fi

# Generate new password
NEW_PASSWORD=$($WP_CLI eval 'echo wp_generate_password(16, true, true);' --allow-root --skip-plugins)

# Reset password
$WP_CLI user update "$EMAIL" --user_pass="$NEW_PASSWORD" --allow-root --skip-plugins

echo "✅ Password reset successfully for: $EMAIL"
echo ""
echo "📋 New Password: $NEW_PASSWORD"
echo ""
echo "⚠️  Copy this password now - it won't be shown again!"
