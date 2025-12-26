Plugins & Themes Inventory Report
=================================

Generated: 2025-12-22

Notes: this report was produced by scanning plugin main PHP headers and theme style.css files under `wp-data/wp-content`.

Environment baseline (from `infra/dev/compose.yml`):
- WordPress image: `wordpress:6.9.0-php8.3-apache` (PHP 8.3, WP 6.9.0)

Plugins
-------

- Akismet Anti-spam: Spam Protection
  - Folder: `akismet`
  - Plugin file: `akismet.php`
  - Version: 5.6
  - Requires at least WP: 5.8
  - Requires PHP: 7.2
  - Author: Automattic
  - Notes: Official Automattic plugin. Version header present. Compatible with WP 6.9.0 and PHP 8.3 (requires PHP 7.2+).

- Blocksy Companion
  - Folder: `blocksy-companion`
  - Plugin file: `blocksy-companion.php`
  - Version: 2.1.23
  - Requires at least WP: 6.5
  - Requires PHP: 7.0
  - Author: CreativeThemes
  - Notes: Companion plugin for the Blocksy theme. Contains Freemius integration and a public key in code; review licensing/telemetry and consider whether freemius startup should be enabled in dev. Compatible with container baseline.

- Elementor
  - Folder: `elementor`
  - Plugin file: `elementor.php`
  - Version: 3.34.0
  - Requires at least WP: 6.5
  - Requires PHP: 7.4
  - Author: Elementor.com
  - Notes: Large 3rd-party builder. Requires PHP 7.4+, OK on PHP 8.3 but some older Elementor versions can have compatibility issues; test editor flows.

- WooCommerce
  - Folder: `woocommerce`
  - Plugin file: `woocommerce.php`
  - Version: 10.4.3
  - Requires at least WP: 6.7
  - Requires PHP: 7.4
  - Author: Automattic
  - Notes: Major ecommerce plugin; keep attention on templates, breakage risk on updates, and compatibility with any custom theme code.

- WPForms Lite
  - Folder: `wpforms-lite`
  - Plugin file: `wpforms.php`
  - Version: 1.9.8.7
  - Requires at least WP: 5.5
  - Requires PHP: 7.2
  - Author: WPForms
  - Notes: Lite version detected; ok for PHP 8.3 though some WPForms components may require testing.

Themes
------

- Blocksy
  - Folder: `blocksy`
  - Version: 2.1.9
  - Requires PHP: 7.0
  - Tested up to: 6.8
  - Notes: Commercial/theme framework; companion plugin present.

- Twenty Twenty-Five
  - Folder: `twentytwentyfive`
  - Version: 1.3
  - Requires PHP: 7.2

- Twenty Twenty-Four
  - Folder: `twentytwentyfour`
  - Version: 1.3
  - Requires PHP: 7.0

- Twenty Twenty-Three
  - Folder: `twentytwentythree`
  - Version: 1.6
  - Requires PHP: 5.6

Summary findings and recommendations
-----------------------------------

- Compatibility: All plugins and themes declare PHP minimums <= 7.4, so they should run on PHP 8.3, but some plugins (Elementor, WooCommerce) have large codebases and can expose runtime incompatibilities on major PHP changes — recommend running full integration smoke tests (editor, checkout, form submit).

- Updates: I could not check remote plugin versions. Run WP-CLI or `wp plugin list` inside the running container to see which plugins/themes have updates available.
  - Example: `podman exec -it wordpress wp plugin list --format=json`
  - Example: `podman exec -it wordpress wp theme list --format=json`

- Custom code detection: all installed plugins appear to be standard packages with standard headers. No obviously custom plugins were found. If you maintain custom modifications, check the plugin folders for local patches or non-upstream files (for example `freemius/start.php` references in Blocksy Companion are part of the plugin distribution, not necessarily custom). If you'd like, I can run a simple checksum-based diff against a fresh upstream install (requires network access) or scan for files that mention your organization.

- Telemetry/3rd-party SDKs: `blocksy-companion` includes Freemius usage. If privacy/data exfiltration is a concern, audit that integration.

- Security scanning: For CVE and vulnerability checks, consider adding WPScan to the dev environment or running `wp plugin list --format=json` and cross-referencing versions with wpvulndb or an automated scanner. WPScan requires an API token for large scans.

Next steps (awaiting your approval)
---------------------------------
1. Inspect Docker and HTTPD/PHP config (`infra/dev/compose.yml`, `config/.htaccess`, `config/uploads.ini`) for PHP/Apache versions, upload limits, and security settings. (I'll run this next if you confirm.)
2. Plan DB datadir -> SQL migration.
3. Propose compose changes for init SQL usage.
