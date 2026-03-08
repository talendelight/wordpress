<?php
// Enqueue child theme stylesheet
add_action('wp_enqueue_scripts', function() {
    // Design tokens - CSS custom properties (MUST load first)
    wp_enqueue_style(
        'td-design-tokens',
        get_stylesheet_directory_uri() . '/design-tokens.css',
        array(),  // No dependencies - this is the foundation
        '3.2.0'
    );
    
    // Base styles - global defaults and layout wrappers
    wp_enqueue_style(
        'td-base',
        get_stylesheet_directory_uri() . '/assets/css/base.css',
        array('td-design-tokens'),
        '3.2.0'
    );
    
    // Components - reusable UI components (buttons, utilities)
    wp_enqueue_style(
        'td-components',
        get_stylesheet_directory_uri() . '/assets/css/components.css',
        array('td-design-tokens', 'td-base'),
        '3.2.0'
    );
    
    // Plugin overrides - WPUM (login, registration, profile forms)
    wp_enqueue_style(
        'td-plugin-wpum',
        get_stylesheet_directory_uri() . '/assets/css/plugin-wpum.css',
        array('td-design-tokens', 'td-base', 'td-components'),
        '3.2.0'
    );
    
    // Plugin overrides - Forminator (forms)
    wp_enqueue_style(
        'td-plugin-forminator',
        get_stylesheet_directory_uri() . '/assets/css/plugin-forminator.css',
        array('td-design-tokens', 'td-base', 'td-components'),
        '3.2.0'
    );
    
    // Main child theme stylesheet
    wp_enqueue_style(
        'blocksy-child-style',
        get_stylesheet_uri(),
        array('td-design-tokens', 'td-base', 'td-components'),  // Depends on design system
        '3.2.0'
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
    
    // Google Fonts - Red Hat Display Black 900 (for site logo)
    wp_enqueue_style(
        'google-font-red-hat-display',
        'https://fonts.googleapis.com/css2?family=Red+Hat+Display:wght@900&display=swap',
        array(),
        null
    );
    
    // Registration form assets (only on registration page)
    // Debug: Always enqueue to test if this is the issue
    if (is_page()) {
        $current_page = get_queried_object();
        $page_slug = isset($current_page->post_name) ? $current_page->post_name : 'unknown';
        
        // Log for debugging (will appear in error_log)
        error_log('Page slug: ' . $page_slug . ', is_page: ' . (is_page() ? 'yes' : 'no'));
        
        // Enqueue for register-profile page
        if ($page_slug === 'register-profile') {
            wp_enqueue_style(
                'td-registration-form',
                get_stylesheet_directory_uri() . '/assets/css/registration-form.css',
                array('td-design-tokens', 'blocksy-child-style'),
                '1.0.1'  // Bumped version to force reload
            );
            
            wp_enqueue_script(
                'td-registration-form',
                get_stylesheet_directory_uri() . '/assets/js/registration-form.js',
                array(),
                '1.0.6',  // Added form data debugging
                true
            );
            
            error_log('Enqueued registration scripts for: ' . $page_slug);
        }
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

// Redirect after logout to Welcome page (home page)
// Uses logout_redirect filter instead of wp_logout action to ensure proper redirect
add_filter('logout_redirect', function($redirect_to, $requested_redirect_to, $user) {
    return home_url('/');  // Welcome page is set as front page (ID 6)
}, 10, 3);

// Role-based page access control (MVP - Replace with plugin in v3.7.0+)
// TODO v3.7.0: Migrate to PublishPress Capabilities or similar plugin
add_action('template_redirect', function() {
    if (!is_page()) {
        return;
    }
    
    $current_user = wp_get_current_user();
    $is_logged_in = is_user_logged_in();
    $current_url = $_SERVER['REQUEST_URI'];
    
    // Role-specific landing pages and subpages (require login + specific role)
    $role_pages = [
        '/candidates/' => 'td_candidate',    // Candidates only (landing + subpages)
        '/employers/' => 'td_employer',      // Employers only (landing + subpages)
        '/scouts/' => 'td_scout',            // Scouts only (landing + subpages)
        '/managers/' => 'td_manager',        // Managers only (landing + /managers/admin/, /managers/actions/, etc.)
    ];
    
    foreach ($role_pages as $url_prefix => $required_role) {
        if (strpos($current_url, $url_prefix) === 0) {
            // Redirect to login if not authenticated
            if (!$is_logged_in) {
                wp_redirect(home_url('/log-in/?redirect_to=' . urlencode($current_url)));
                exit;
            }
            
            // Check if user has the required role (or is administrator)
            if (!array_intersect(['administrator', $required_role], $current_user->roles)) {
                wp_redirect(home_url('/403-forbidden/'));
                exit;
            }
        }
    }
    
    // Operator pages (accessible by Operators OR Managers)
    if (strpos($current_url, '/operators/') === 0) {
        if (!array_intersect(['administrator', 'td_operator', 'td_manager'], $current_user->roles)) {
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
        
        // Replace logout URL with proper nonce to skip confirmation page
        if (strpos($url, 'action=logout') !== false) {
            $item->url = wp_logout_url(home_url('/'));
        }
        
        // Hide Register and Login when logged in
        if ($logged_in && (strpos($url, '/register') !== false || strpos($url, '/select-role') !== false || strpos($url, '/log-in') !== false)) {
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

// Note: manager_actions_table shortcode is registered in /wp-content/mu-plugins/manager-actions-display.php
// Do not register here to avoid conflicts

// Add tab switching JavaScript to Manager Actions page
add_action('wp_footer', function() {
    if (!is_page('actions')) {
        return;
    }
    ?>
    <script>
    (function() {
        const tabButtons = document.querySelectorAll('.td-tab-button');
        const tabContents = document.querySelectorAll('.td-tab-content');
        
        if (tabButtons.length === 0) return;
        
        // Ensure inactive tabs are hidden
        tabContents.forEach((content, index) => {
            if (!content.classList.contains('active')) {
                content.style.display = 'none';
            }
        });
        
        // Ensure tab nav has flexbox
        const tabNav = document.querySelector('.td-tab-nav');
        if (tabNav) {
            tabNav.style.display = 'flex';
        }
        
        tabButtons.forEach(button => {
            button.addEventListener('click', function() {
                const targetTab = this.getAttribute('data-tab');
                
                tabButtons.forEach(btn => {
                    btn.classList.remove('active');
                    btn.style.borderBottomColor = 'transparent';
                    btn.style.color = '#666';
                    btn.style.background = '#f8f8f8';
                });
                
                tabContents.forEach(content => {
                    content.classList.remove('active');
                    content.style.display = 'none';
                });
                
                this.classList.add('active');
                this.style.borderBottomColor = '#3498DB';
                this.style.color = '#063970';
                this.style.background = this.getAttribute('data-color');
                
                const targetContent = document.getElementById('tab-' + targetTab);
                if (targetContent) {
                    targetContent.classList.add('active');
                    targetContent.style.display = 'block';
                }
            });
            
            button.addEventListener('mouseenter', function() {
                if (!this.classList.contains('active')) {
                    this.style.borderBottomColor = '#3498DB';
                    this.style.background = this.getAttribute('data-color');
                }
            });
            
            button.addEventListener('mouseleave', function() {
                if (!this.classList.contains('active')) {
                    this.style.borderBottomColor = 'transparent';
                    this.style.background = '#f8f8f8';
                }
            });
        });
    })();
    </script>
    <?php
});

