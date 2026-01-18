# ID Management Strategy

**Problem:** WordPress IDs (pages, posts, forms, etc.) differ between local and production environments, making deployments fragile and error-prone.

**Solution:** Use slug-based lookups with ID mapping manifest for cross-references.

---

## Core Principles

### 1. Always Use Slugs for Lookups

❌ **DON'T:**
```bash
# Hardcoded ID - will break across environments
wp post meta update 79 _elementor_data ...
```

✅ **DO:**
```bash
# Lookup by slug first
PAGE_ID=$(wp post list --post_type=page --name=register-profile --field=ID)
wp post meta update $PAGE_ID _elementor_data ...
```

### 2. Maintain ID Mapping Manifest

File: `infra/shared/elementor-manifest.json`

Purpose:
- Track page/form slugs across environments
- Document which content needs ID replacement
- Provide lookup commands for deployment scripts

### 3. Use Deployment Scripts for ID Replacement

Never manually replace IDs. Use:
- `infra/shared/scripts/deploy-id-mapper.php` - Replaces IDs in Elementor data

---

## Manifest Structure

```json
{
  "version": "3.4.0",
  "strategy": "Use slugs for lookups, maintain ID mappings",
  "pages": [
    {
      "name": "register-profile",
      "slug": "register-profile",
      "local_id": "TBD",
      "prod_id": 79,
      "notes": "Uses Forminator shortcode"
    }
  ],
  "forms": [
    {
      "name": "person-registration",
      "slug": "person-registration-form",
      "type": "forminator_forms",
      "local_id": "TBD",
      "prod_id": 80
    }
  ],
  "lookup_strategy": {
    "pages": "wp post list --post_type=page --name={slug} --field=ID",
    "forms": "wp post list --post_type=forminator_forms --name={slug} --field=ID"
  }
}
```

---

## Deployment Workflows

### Scenario 1: Deploy New Page (No Cross-References)

```bash
# 1. Create page in production by slug
wp post create --post_type=page --post_title="My Page" --post_name=my-page --post_status=publish

# 2. Get ID for manifest
PROD_ID=$(wp post list --post_type=page --name=my-page --field=ID)
echo "Production ID: $PROD_ID"

# 3. Update manifest with production ID
```

### Scenario 2: Deploy Page with Form References

**Problem:** Page contains `[forminator_form id="364"]` but production form ID is `80`

**Solution:**

```bash
# 1. Upload page content with local IDs
scp tmp/register-profile.json production:~/

# 2. Run ID mapper script on production
ssh production "cd domains/talendelight.com/public_html && \
  wp eval-file ~/scripts/deploy-id-mapper.php -- \
  --page-slug=register-profile \
  --form-slug=person-registration-form"

# 3. Script automatically:
#    - Looks up page ID by slug (register-profile → 79)
#    - Looks up form ID by slug (person-registration-form → 80)
#    - Replaces all references: 364 → 80
#    - Updates both shortcodes and Gutenberg blocks
```

### Scenario 3: Deploy New Form

```bash
# 1. Export form from local
# (Forminator doesn't have good export, so recreate manually or use WP All Export)

# 2. Create form in production via UI or import

# 3. Get slug and ID
FORM_SLUG=$(wp post list --post_type=forminator_forms --field=post_name | head -1)
FORM_ID=$(wp post list --post_type=forminator_forms --field=ID | head -1)

# 4. Update manifest
echo "Form: $FORM_SLUG = ID $FORM_ID"
```

---

## Common ID Replacement Patterns

### Pattern 1: Forminator Shortcode in Elementor

**Shortcode format:**
```
[forminator_form id="364"]
```

**Gutenberg block format:**
```json
{"module_id":"364"}
```

**Both must be replaced** - the deployment script handles this automatically.

### Pattern 2: Internal Page Links

**Problem:** Elementor buttons with URL `/page/?p=123`

**Solution:** Use relative slugs `/my-page/` instead of `/?p=ID`

### Pattern 3: Image IDs in Elementor

**Problem:** Background images reference attachment IDs

**Current:** Manual - upload images first, note IDs
**Future:** Consider media sync strategy

---

## Workflow Integration

### Local Development

1. Build features using local environment
2. Use **any IDs** - they will be replaced during deployment
3. Note which pages reference which forms/content
4. Update `elementor-manifest.json` with slugs

### Deployment

1. Export Elementor pages: `pwsh infra/shared/scripts/export-elementor-pages.ps1`
2. Upload to production
3. Run ID mapper: `wp eval-file deploy-id-mapper.php --page-slug=X --form-slug=Y`
4. Verify in browser

### Post-Deployment

1. Update manifest with actual production IDs
2. Commit manifest updates to git
3. Document any manual ID replacements needed

---

## Tools Reference

### Lookup ID by Slug (Pages)

```bash
wp post list --post_type=page --name=SLUG --field=ID
```

### Lookup ID by Slug (Forms)

```bash
wp post list --post_type=forminator_forms --name=SLUG --field=ID
```

### Lookup ID by Title

```bash
wp post list --post_type=page --s="Exact Title" --field=ID
```

### Get Slug from ID

```bash
wp post get ID --field=post_name
```

### Batch Lookup

```bash
# Get all form slugs and IDs
wp post list --post_type=forminator_forms --format=csv --fields=ID,post_name,post_title
```

---

## Manifest Maintenance

### When to Update

- ✅ After creating new page/form in production
- ✅ After deployment with ID replacements
- ✅ When local IDs change (ephemeral database reset)
- ❌ NOT during development (local IDs don't matter)

### Update Process

1. Get current production IDs:
   ```bash
   ssh production "cd domains/talendelight.com/public_html && \
     wp post list --post_type=page --format=json --fields=ID,post_name,post_title" > tmp/prod-pages.json
   ```

2. Update `infra/shared/elementor-manifest.json`

3. Commit to git:
   ```bash
   git add infra/shared/elementor-manifest.json
   git commit -m "Update manifest with production IDs"
   ```

---

## Limitations & Future Improvements

### Current Limitations

1. **Forms:** Forminator forms must be created manually in production (no good export)
2. **Media:** Image/attachment IDs not automatically mapped
3. **Widgets:** Some Elementor widgets may have hardcoded IDs
4. **Users:** User IDs differ between environments

### Future Enhancements

1. Automated form import/export via Forminator API
2. Media library sync with ID mapping
3. GitHub Actions integration for automatic ID replacement
4. Pre-flight check script to validate all referenced IDs exist

---

## Examples

### Example 1: Register Profile Page with Form

**Manifest Entry:**
```json
{
  "pages": [
    {
      "name": "register-profile",
      "slug": "register-profile",
      "local_id": "TBD",
      "prod_id": 79
    }
  ],
  "forms": [
    {
      "name": "person-registration",
      "slug": "person-registration-form",
      "local_id": "TBD",
      "prod_id": 80
    }
  ]
}
```

**Deployment:**
```bash
# Upload Elementor export
scp tmp/elementor-exports/register-profile.json production:~/

# Import with ID mapping
ssh production "cd ~/domains/talendelight.com/public_html && \
  wp eval-file ~/scripts/deploy-id-mapper.php -- \
  --page-slug=register-profile \
  --form-slug=person-registration-form"
```

**Result:**
- Page found by slug `register-profile` → ID 79
- Form found by slug `person-registration-form` → ID 80
- All references updated: `[forminator_form id="X"]` → `[forminator_form id="80"]`

---

## Troubleshooting

### Issue: "Form not found with slug"

**Cause:** Form doesn't exist in production or slug is wrong

**Fix:**
```bash
# Check actual form slug
ssh production "wp post list --post_type=forminator_forms --format=table --fields=ID,post_name,post_title"

# Update manifest with correct slug
```

### Issue: "No Elementor data found"

**Cause:** Page not using Elementor

**Fix:** Check page template. Custom PHP templates don't use Elementor data.

### Issue: "IDs not replaced"

**Cause:** ID format in Elementor data doesn't match regex patterns

**Fix:**
1. Export current Elementor data
2. Inspect JSON structure
3. Update `deploy-id-mapper.php` regex patterns
4. Re-run deployment

---

## Best Practices

1. ✅ **Always use slugs in scripts** - Never hardcode IDs
2. ✅ **Update manifest immediately** - Don't wait until next deployment
3. ✅ **Test ID mapper locally first** - Run against local database copy
4. ✅ **Document custom IDs** - Note any manual replacements in manifest
5. ✅ **Keep manifest in sync** - Commit updates after every deployment
6. ❌ **Don't skip ID mapping** - Manual replacements will be overwritten
7. ❌ **Don't use post IDs in URLs** - Use slugs: `/my-page/` not `/?p=123`
8. ❌ **Don't assume IDs match** - Always lookup, even if they seem sequential
