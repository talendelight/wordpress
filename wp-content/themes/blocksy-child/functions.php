<?php
// Enqueue child theme stylesheet
add_action('wp_enqueue_scripts', function() {
    // Main child theme stylesheet
    wp_enqueue_style('blocksy-child-style', get_stylesheet_uri());
    
    // Custom color palette CSS
    wp_enqueue_style(
        'blocksy-child-colors',
        get_stylesheet_directory_uri() . '/custom-colors.css',
        array('blocksy-child-style'),
        '1.0.1'
    );
    
    // WPUM form overrides (design system integration)
    wp_enqueue_style(
        'wpum-design-system', 
        get_stylesheet_directory_uri() . '/wpum-overrides.css',
        array('blocksy-child-style'),
        '1.0.0'
    );
    
    // Font Awesome - fallback if Better Font Awesome plugin not active
    if (!wp_style_is('font-awesome', 'enqueued') && !wp_style_is('font-awesome-official', 'enqueued')) {
        wp_enqueue_style(
            'font-awesome-cdn',
            'https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.5.1/css/all.min.css',
            array(),
            '6.5.1'
        );
    }
});

// Register block patterns
add_action('init', function() {
    // Register block pattern category
    register_block_pattern_category('talendelight', array(
        'label' => __('TalenDelight', 'blocksy-child')
    ));
    
    // Manually register patterns (WordPress 6.9 auto-registration seems incomplete)
    $patterns_dir = get_stylesheet_directory() . '/patterns/';
    $pattern_files = glob($patterns_dir . '*.php');
    
    foreach ($pattern_files as $pattern_file) {
        $slug = basename($pattern_file, '.php');
        
        // Skip if already registered (avoid duplicates)
        if (WP_Block_Patterns_Registry::get_instance()->is_registered('blocksy-child/' . $slug)) {
            continue;
        }
        
        // Get pattern content
        ob_start();
        include $pattern_file;
        $content = ob_get_clean();
        
        // Extract metadata from PHP doc comment
        $headers = get_file_data($pattern_file, array(
            'title' => 'Title',
            'slug' => 'Slug',
            'description' => 'Description',
            'categories' => 'Categories',
        ));
        
        // Parse categories (comma-separated string to array)
        $categories = array_map('trim', explode(',', $headers['categories']));
        
        // Register the pattern
        if (!empty($headers['title']) && !empty($content)) {
            register_block_pattern($headers['slug'] ?: 'blocksy-child/' . $slug, array(
                'title' => $headers['title'],
                'description' => $headers['description'] ?: '',
                'content' => $content,
                'categories' => $categories,
            ));
        }
    }
}, 9);

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
