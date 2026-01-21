# Environment Configuration

## Overview

TalenDelight uses environment-specific configuration to handle differences between local development and production environments (e.g., form IDs, page IDs).

## Configuration File

**Location:** `wp-content/mu-plugins/td-env-config.php`

**Deployment:** Automatically deployed via Git (as part of wp-content/)

This file is automatically loaded by `wp-config.php` and defines constants based on environment detection.

## Environment Detection

The configuration automatically detects the environment using multiple methods:

1. **Hostname check:** Checks for `localhost` or `127.0.0.1`
2. **Server name:** Checks `$_SERVER['SERVER_NAME']`
3. **Environment variable:** Uses `WP_ENV` if set

## Available Constants

### Core Configuration

- `TD_ENVIRONMENT` - Current environment: `'local'` or `'production'`
- `TD_DEBUG` - Debug flag (true for local, false for production)

### Form IDs

- `TD_PERSON_REGISTRATION_FORM_ID`
  - Local: `364`
  - Production: `80`

### Page IDs

- `TD_WELCOME_PAGE_ID`
  - Local: `20`
  - Production: `14`

- `TD_SELECT_ROLE_PAGE_ID`
  - Local: `379`
  - Production: `78`

- `TD_REGISTER_PROFILE_PAGE_ID`
  - Local: `365`
  - Production: `79`

- `TD_MANAGER_ADMIN_PAGE_ID`
  - Local: `386`
  - Production: `86`

- `TD_MANAGERS_PAGE_ID`
  - Local: `469`
  - Production: TBD

## Usage in Code

### PHP Theme/Plugin Code

```php
// Get form ID for current environment
$form_id = TD_PERSON_REGISTRATION_FORM_ID;

// Check environment
if (TD_ENVIRONMENT === 'local') {
    // Local-only code
}

// Use in filters/actions
add_filter('forminator_custom_form_submit_response', function($response, $form_id, $entry) {
    if ((int)$form_id === (int)TD_PERSON_REGISTRATION_FORM_ID) {
        // Handle form submission
    }
    return $response;
}, 10, 3);
```

### MU-Plugins

```php
function my_forminator_handler($form_id, $response) {
    // Use constant instead of hardcoded value
    if ((int)$form_id === (int)TD_PERSON_REGISTRATION_FORM_ID) {
        // Process form
    }
}
```

## Adding New Configuration Values

1. Edit `wp-content/mu-plugins/td-env-config.php`
2. Add new constant with environment-specific logic:

```php
if (!defined('TD_MY_NEW_SETTING')) {
    define('TD_MY_NEW_SETTING', $is_local ? 'local_value' : 'production_value');
}
```

3. Use the constant in your code
4. Document it in this file

## Benefits

✅ **Single source of truth** - All environment-specific values in one place  
✅ **No hardcoded arrays** - Clean, maintainable code  
✅ **Automatic detection** - No manual switching needed  
✅ **Type safety** - Constants provide better IDE support  
✅ **Easy maintenance** - Update values in one file, not scattered across codebase

## Files Using Environment Config

- `wp-content/themes/blocksy-child/functions.php` - Form submission redirect
- `wp-content/mu-plugins/forminator-custom-table.php` - Form data sync
- (Add more as needed)

## Deployment Notes

### Local Development Setup

The local Docker/Podman environment is configured to:
1. Mount `config/env-config.php` to `/var/www/html/env-config.php`
2. Set `WP_ENV=local` environment variable (for CLI access)
3. Automatically detect local environment via `DB_HOST=wp-db` check

See [infra/dev/compose.yml](../infra/dev/compose.yml) for the complete configuration.

### Production Deployment

When deploying to production, ensure `config/env-config.php` is included in the deployment. The file automatically detects production environment based on database hostname (anything other than `wp-db`).

### Manual Environment Override

If automatic detection fails, you can set the `WP_ENV` environment variable:

```bash
# In docker-compose.yml or .env
WP_ENV=development  # or 'production'
```

## Troubleshooting

### Constants Not Defined

If you get "undefined constant" errors:

1. Check that `config/env-config.php` exists
2. Verify it's being loaded in `config/wp-config.php`
3. Clear WordPress cache: `wp cache flush`

### Wrong Environment Detected

Check the environment detection logic in `config/env-config.php` and adjust as needed for your hosting setup.

### Production Values Need Update

Edit `config/env-config.php` and update the production values in the `!$is_local` branches.

## Related Documentation

- [DEPLOYMENT-WORKFLOW.md](DEPLOYMENT-WORKFLOW.md) - Deployment process
- [ID-MANAGEMENT-STRATEGY.md](ID-MANAGEMENT-STRATEGY.md) - Cross-environment ID handling
