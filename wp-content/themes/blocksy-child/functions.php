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

// Redirect after Forminator Person Registration Form submission (ID: 364)
add_filter('forminator_custom_form_submit_response', function($response, $form_id, $entry) {
    // Only apply to Person Registration Form (ID: 364)
    if ($form_id == 364 && isset($response['success']) && $response['success']) {
        // Force redirect to welcome page
        $response['url'] = home_url('/welcome/');
        $response['newtab'] = 'sametab';
        // Ensure behavior is set to redirect
        $response['behavior'] = 'redirect';
    }
    return $response;
}, 20, 3); // Increased priority to 20 to run later

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
