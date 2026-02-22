# RESTORE FOLDER - LATEST BACKUP
Last Updated: 2026-02-20 23:29:48

## Pages (restore/pages/)
- Manager Actions (36): Footer with SVG icons
- Manager Admin (38): Footer with SVG icons  
- Register Profile (21): AJAX form with floating messages, button colors #063970/#2872fa

## MU-Plugins (restore/mu-plugins/)
- td-registration-handler.php: v2.0.0 - Creates change requests, NOT WordPress users
- manager-actions-display.php: Manager Actions table shortcode
- record-id-generator.php: ID sequence generator (USRQ/PRSN/CMPY)

## Theme (restore/)
- css/style.css: Button colors (#063970 default, #2872fa hover), site-wide styles
- patterns/*.php: Custom block patterns (card-grid, hero, CTA, footer)
- functions.php: Theme customizations

## Key Changes (Feb 20, 2026)
✓ Footer icons: Replaced emojis with SVG images (shield, padlock, balance-scale, EU logo)
✓ Registration handler: Rewritten to use change requests table instead of WordPress users
✓ Button colors: Standardized across site (#063970 default, #2872fa hover)
✓ Floating messages: Added to registration form with 2s auto-hide + redirect

## Workflow Notes
- Registrations create records in td_user_data_change_requests (status: 'new')
- Manager approval sets status to 'approved' but does NOT create WordPress users
- User provisioning is external process (see WORDPRESS-BACKLOG.md -> Epic WP-09.5)
