<?php
// Redirect default register page to custom role selection page
add_action('template_redirect', function() {
    if (is_page('register')) {
        wp_redirect(site_url('/select-role/'));
        exit;
    }
});

// Redirect WordPress logout to Welcome page (home page)
add_action('wp_logout', function() {
    wp_redirect(home_url('/'));
    exit;
});

// Conditionally hide/show Login and Logout menu items based on user login status
add_filter('wp_nav_menu_items', function($items, $args) {
    // Only apply to Header Menu (or all menus if not specified)
    if ($items) {
        if (is_user_logged_in()) {
            // Hide "Log In" menu item when logged in
            $items = preg_replace('/<li[^>]*class="[^"]*menu-item-149[^"]*"[^>]*>.*?<\/li>/s', '', $items);
        } else {
            // Hide "Log Out" menu item when logged out
            $items = preg_replace('/<li[^>]*class="[^"]*menu-item-150[^"]*"[^>]*>.*?<\/li>/s', '', $items);
        }
    }
    return $items;
}, 10, 2);
