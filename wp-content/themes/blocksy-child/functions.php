<?php
// Enqueue child theme stylesheet
add_action('wp_enqueue_scripts', function() {
    // Main child theme stylesheet
    wp_enqueue_style('blocksy-child-style', get_stylesheet_uri());
    
    // WPUM form overrides (design system integration)
    wp_enqueue_style(
        'wpum-design-system', 
        get_stylesheet_directory_uri() . '/wpum-overrides.css',
        array('blocksy-child-style'),
        '1.0.0'
    );
    
    // Font Awesome now loaded via Better Font Awesome plugin (locally hosted)
});

// Redirect /register/ page to custom role selection page
add_action('template_redirect', function() {
    global $post;
    if (is_page() && $post && $post->post_name === 'register' && $post->post_parent == 0) {
        wp_redirect(site_url('/roles/select/'));
        exit;
    }
});

// Redirect WordPress default login to custom login page
add_action('init', function() {
    // Redirect wp-login.php to custom login page (except for logout and admin requests)
    if (isset($_SERVER['REQUEST_URI']) && 
        strpos($_SERVER['REQUEST_URI'], 'wp-login.php') !== false &&
        !isset($_GET['action']) && 
        !is_user_logged_in()) {
        wp_redirect(home_url('/log-in/'));
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

// Conditionally hide/show menu items based on user login status
add_filter('wp_nav_menu_objects', function($items, $args) {
    // Debug: log to see if this runs
    error_log('Menu filter running. Logged in: ' . (is_user_logged_in() ? 'yes' : 'no') . '. Items count: ' . count($items));
    
    $logged_in = is_user_logged_in();
    
    foreach ($items as $key => $item) {
        $url = $item->url;
        error_log("Menu item: {$item->title} - URL: {$url}");
        
        // Hide Register and Login when logged in
        if ($logged_in && (strpos($url, '/register') !== false || strpos($url, '/log-in') !== false)) {
            error_log("Removing {$item->title} (logged in)");
            unset($items[$key]);
        }
        
        // Hide Profile and Logout when logged out
        if (!$logged_in && (strpos($url, '/profile') !== false || strpos($url, '/logout') !== false || strpos($url, 'action=logout') !== false)) {
            error_log("Removing {$item->title} (logged out)");
            unset($items[$key]);
        }
    }
    
    return $items;
}, 10, 2);
