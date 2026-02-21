# Custom Roles & Test Users Persistence

## Problem

When recreating the database with `podman-compose down -v`, the following are lost:
1. **Custom roles** (td_candidate, td_employer, td_scout, td_operator, td_manager)
2. **Plugin activation** (talendelight-roles plugin)
3. **Test users** with custom roles

## Solution Implemented

### 1. Plugin Activation (Required for Roles)

**File:** [260219-1630-activate-talendelight-roles.sql](infra/shared/db/260219-1630-activate-talendelight-roles.sql)

- Activates `talendelight-roles` plugin on fresh database
- Removes `talendelight_roles_registered` flag to trigger role registration
- Plugin auto-registers 5 custom roles on next page load

### 2. Test Users Creation (Optional)

**File:** [260219-1640-create-test-users.sql](infra/shared/db/260219-1640-create-test-users.sql)

- Creates 5 test users (one per custom role)
- Password: `Test123!` (all users)
- Uses `ON DUPLICATE KEY UPDATE` to be idempotent

**Test Users:**
- candidate-test@talendelight.com (td_candidate)
- employer-test@talendelight.com (td_employer)  
- scout-test@talendelight.com (td_scout)
- operator-test@talendelight.com (td_operator)
- manager-test@talendelight.com (td_manager)

### 3. How It Works

**During database initialization:**
```
1. 000000-0000-init-db.sql          → Baseline WordPress database
2. 260219-1630-activate-talendelight-roles.sql → Activates plugin
3. 260219-1640-create-test-users.sql → Creates test users (optional)
4. ... other delta files in sequence
```

**After container startup:**
- Plugin activation triggers role registration via `after_setup_theme` hook
- Custom roles available immediately: td_candidate, td_employer, td_scout, td_operator, td_manager
- Test users ready for login

## Verification After Database Recreation

```powershell
# 1. Recreate database
podman-compose down -v && podman-compose up -d

# 2. Wait for containers to start (30 seconds)
Start-Sleep -Seconds 30

# 3. Verify custom roles registered
podman exec wp wp role list --allow-root --format=table

# Expected output (should include):
# Employer        td_employer
# Candidate       td_candidate
# Scout           td_scout
# Operator        td_operator
# Manager         td_manager

# 4. Verify test users exist
podman exec wp wp user list --allow-root --format=table

# Expected output (should include 5 test users with custom roles)

# 5. Test login
# Visit: https://wp.local/log-in/
# Username: candidate-test (or any test user)
# Password: Test123!
```

## Alternative: WP-CLI Approach (Manual)

If you prefer to skip SQL-based user creation and create users manually after database recreation:

```powershell
podman exec wp bash -c "
wp user create candidate-test candidate-test@talendelight.com --role=td_candidate --user_pass='Test123!' --display_name='Test Candidate' --first_name='Test' --last_name='Candidate' --allow-root
wp user create employer-test employer-test@talendelight.com --role=td_employer --user_pass='Test123!' --display_name='Test Employer' --first_name='Test' --last_name='Employer' --allow-root
wp user create scout-test scout-test@talendelight.com --role=td_scout --user_pass='Test123!' --display_name='Test Scout' --first_name='Test' --last_name='Scout' --allow-root
wp user create operator-test operator-test@talendelight.com --role=td_operator --user_pass='Test123!' --display_name='Test Operator' --first_name='Test' --last_name='Operator' --allow-root
wp user create manager-test manager-test@talendelight.com --role=td_manager --user_pass='Test123!' --display_name='Test Manager' --first_name='Test' --last_name='Manager' --allow-root
"
```

## Troubleshooting

### Roles Not Appearing

```powershell
# Check if plugin is active
podman exec wp wp plugin list --allow-root

# Activate plugin if needed
podman exec wp wp plugin activate talendelight-roles --allow-root

# Force role registration
podman exec wp wp option delete talendelight_roles_registered --allow-root
# Then reload any page to trigger role registration
```

### Test Users Login Fails

```powershell
# Reset password for test user
podman exec wp wp user update candidate-test --user_pass='Test123!' --allow-root

# Or recreate user
podman exec wp wp user delete candidate-test --yes --allow-root
podman exec wp wp user create candidate-test candidate-test@talendelight.com --role=td_candidate --user_pass='Test123!' --display_name='Test Candidate' --allow-root
```

## Files Modified

1. **[infra/shared/db/260219-1630-activate-talendelight-roles.sql](infra/shared/db/260219-1630-activate-talendelight-roles.sql)** - Plugin activation
2. **[infra/shared/db/260219-1640-create-test-users.sql](infra/shared/db/260219-1640-create-test-users.sql)** - Test users creation
3. **[wp-content/plugins/talendelight-roles/](wp-content/plugins/talendelight-roles/)** - Custom roles plugin (already in git)

## Key Takeaways

✅ **Plugin activation persists** - Delta SQL file ensures plugin is activated on fresh database  
✅ **Roles auto-register** - Plugin hooks into WordPress lifecycle to register roles  
✅ **Test users optional** - SQL file included but can be omitted if not needed  
✅ **Idempotent** - Can run delta files multiple times safely  
✅ **Version controlled** - All changes tracked in git
