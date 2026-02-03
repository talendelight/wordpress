<?php
// Redirect default register page to custom role selection page
// Only redirect the top-level /register/ page, not child pages like /persons/register/
add_action('template_redirect', function() {
    global $post;
    if (is_page() && $post && $post->post_name === 'register' && $post->post_parent == 0) {
        wp_redirect(site_url('/roles/select/'));
        exit;
    }
});

// Redirect WordPress logout to Welcome page (home page)
add_action('wp_logout', function() {
    wp_redirect(home_url('/'));
    exit;
});

// Role-based page access control (MVP - Replace with plugin in v3.7.0+)
// TODO v3.7.0: Migrate to PublishPress Capabilities or similar plugin
add_action('template_redirect', function() {
    if (!is_page()) {
        return;
    }
    
    $page_id = get_the_ID();
    $current_user = wp_get_current_user();
    
    // Manager-only pages (Dashboard, Admin, Actions)
    $manager_pages = [386, 469, 670];
    if (in_array($page_id, $manager_pages)) {
        if (!array_intersect(['administrator', 'td_manager'], $current_user->roles)) {
            wp_redirect(home_url('/403-forbidden/'));
            exit;
        }
    }
    
    // Operator pages (Dashboard, Actions)
    $operator_pages = [299, 666];
    if (in_array($page_id, $operator_pages)) {
        if (!array_intersect(['administrator', 'td_operator'], $current_user->roles)) {
            wp_redirect(home_url('/403-forbidden/'));
            exit;
        }
    }
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
