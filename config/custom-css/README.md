# Custom CSS Files

This directory contains custom CSS files for styling WordPress pages that aren't managed by Elementor.

## Files

### login.css
**Purpose:** Style WP User Manager login form to match Elementor-created landing page aesthetics

**Usage:**
1. **Via WordPress Customizer (Recommended for quick testing):**
   - Navigate to: Appearance → Customize → Additional CSS
   - Copy and paste the contents of `login.css`
   - Click "Publish"

2. **Via Theme Enqueue (Recommended for production):**
   - Create a child theme or use a custom plugin
   - Enqueue the CSS file in your theme's `functions.php`:
   ```php
   function talendelight_enqueue_custom_login_css() {
       wp_enqueue_style(
           'talendelight-login',
           get_stylesheet_directory_uri() . '/custom-css/login.css',
           array(),
           '1.0.0'
       );
   }
   add_action('wp_enqueue_scripts', 'talendelight_enqueue_custom_login_css');
   ```

**Styling Targets:**
- WP User Manager login form (.wpum-login-form)
- Form fields, buttons, labels
- Success/error messages
- Action links (password reset, register)

**Design Consistency:**
- Navy (#063970) - Primary brand color
- White (#FFFFFF) - Form background
- Accent Blue (#3498DB) - Links
- Grey (#898989) - Secondary text
- Matches Elementor landing page button styles and spacing

**Last Updated:** January 11, 2026

## Future Files

Additional custom CSS files can be added here for:
- Button size standards (consider using Elementor's built-in button sizes instead)
- Password reset page styling
- Registration form styling
- Profile page enhancements
- 403 Forbidden page (if not using Elementor)

## Version Control

All CSS files in this directory are version-controlled via Git for consistency across environments.
