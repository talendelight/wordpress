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
                '1.0.7',  // Fixed redirect from /welcome to /about-us
                true
            );
            
            error_log('Enqueued registration scripts for: ' . $page_slug);
        }
        
        // Tab switching script (only on action pages)
        if (in_array($page_slug, ['actions', 'manager-actions'])) {
            wp_enqueue_script(
                'td-tab-switching',
                get_stylesheet_directory_uri() . '/assets/js/tab-switching.js',
                array(),  // No dependencies - vanilla JavaScript
                '1.0.0',  // v3.7.3 - Refactored from inline scripts
                true      // Load in footer for better performance
            );
            
            error_log('Enqueued tab switching script for: ' . $page_slug);
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
    
    // Add "Home" menu item for logged-in users (role-specific landing page)
    if ($logged_in) {
        $current_user = wp_get_current_user();
        $home_url = '';
        
        // Map roles to their landing pages
        $role_landing_pages = [
            'td_candidate' => '/candidates/',
            'td_employer' => '/employers/',
            'td_scout' => '/scouts/',
            'td_manager' => '/managers/',
            'td_operator' => '/operators/',
        ];
        
        // Find user's role and corresponding landing page
        foreach ($current_user->roles as $role) {
            if (isset($role_landing_pages[$role])) {
                $home_url = home_url($role_landing_pages[$role]);
                break;
            }
        }
        
        // Add Home menu item if we found a landing page
        if (!empty($home_url)) {
            $home_item = new stdClass();
            $home_item->ID = 999999; // Unique ID
            $home_item->db_id = 999999;
            $home_item->title = 'Home';
            $home_item->url = $home_url;
            $home_item->menu_order = 0; // First position
            $home_item->menu_item_parent = 0;
            $home_item->type = 'custom';
            $home_item->object = 'custom';
            $home_item->object_id = 999999;
            $home_item->classes = array('menu-item-home');
            
            // Add current-menu-item class if we're on the user's landing page
            $current_url = $_SERVER['REQUEST_URI'];
            $landing_page_slug = str_replace(home_url(), '', $home_url);
            if (strpos($current_url, $landing_page_slug) === 0) {
                $home_item->classes[] = 'current-menu-item';
                $home_item->classes[] = 'current_page_item';
                error_log("Home menu item marked as current (on landing page)");
            }
            
            $home_item->target = '';
            $home_item->attr_title = '';
            $home_item->description = '';
            $home_item->xfn = '';
            $home_item->status = '';
            
            // Insert at the beginning
            array_unshift($items, $home_item);
            
            error_log("Added Home menu item pointing to: {$home_url}");
        }
    }
    
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

// ==============================================================================
// SHORTCODES FOR COMMON PAGE ELEMENTS
// ==============================================================================
// Centralized management of footer badges, hero sections, and CTA sections
// Added: 2026-03-13 as part of v3.7.4 - Page component centralization
// ==============================================================================

/**
 * Footer Trust Badges Shortcode
 * 
 * Displays 4 trust badges (GDPR, Secure & Reliable, Equal Opportunity, EU Markets)
 * Content managed in: wp-content/themes/blocksy-child/includes/footer-badges.html
 * 
 * Usage: [td_footer_badges]
 * 
 * @since v3.7.4
 */
function td_footer_badges_shortcode() {
    $include_file = get_stylesheet_directory() . '/includes/footer-badges.html';
    
    if (file_exists($include_file)) {
        ob_start();
        include $include_file;
        return ob_get_clean();
    }
    
    error_log('TD Shortcode Error: footer-badges.html not found at ' . $include_file);
    return '<!-- Footer badges file not found -->';
}
add_shortcode('td_footer_badges', 'td_footer_badges_shortcode');

/**
 * Hero Section Shortcode
 * 
 * Displays a full-width hero section with optional CTA button
 * 
 * Usage: 
 *   [td_hero title="Your Title" subtitle="Your subtitle"]
 *   [td_hero title="Your Title" subtitle="Your subtitle" cta_display="Button Text" cta_link="/register"]
 *   [td_hero title="Privacy Policy" subtitle=""]  <!-- Legal pages without subtitle -->
 * 
 * @param array $atts Shortcode attributes
 *   - title (string) Required: Main heading text
 *   - subtitle (string) Optional: Subtitle/description text (can be empty for legal pages)
 *   - cta_display (string) Optional: Button display text (if empty, no button shown)
 *   - cta_link (string) Optional: Button URL (default: #)
 * 
 * @since v3.7.4
 */
function td_hero_shortcode($atts) {
    $atts = shortcode_atts([
        'title' => '',
        'subtitle' => '',
        'cta_display' => '',
        'cta_link' => '#'
    ], $atts);
    
    // Validate required attributes (only title is required)
    if (empty($atts['title'])) {
        error_log('TD Shortcode Error: td_hero requires title attribute');
        return '<!-- Hero section requires title -->';
    }
    
    // Load template
    $template_file = get_stylesheet_directory() . '/includes/hero-template.html';
    if (!file_exists($template_file)) {
        error_log('TD Shortcode Error: hero-template.html not found at ' . $template_file);
        return '<!-- Hero template file not found -->';
    }
    
    $html = file_get_contents($template_file);
    
    // Replace placeholders
    $html = str_replace('{{title}}', esc_html($atts['title']), $html);
    $html = str_replace('{{subtitle}}', esc_html($atts['subtitle']), $html);
    
    // Handle optional CTA button
    if (!empty($atts['cta_display'])) {
        $cta_html = '<!-- wp:buttons {"layout":{"type":"flex","justifyContent":"center"},"style":{"spacing":{"margin":{"top":"var(--space-2xl)"}}}} -->' . "\n";
        $cta_html .= '    <div class="wp-block-buttons" style="margin-top:var(--space-2xl);display:flex;justify-content:center">' . "\n";
        $cta_html .= '        <!-- wp:button {"className":"is-style-fill"} -->' . "\n";
        $cta_html .= '        <div class="wp-block-button is-style-fill"><a class="wp-block-button__link wp-element-button" href="' . esc_url($atts['cta_link']) . '">' . esc_html($atts['cta_display']) . '</a></div>' . "\n";
        $cta_html .= '        <!-- /wp:button -->' . "\n";
        $cta_html .= '    </div>' . "\n";
        $cta_html .= '    <!-- /wp:buttons -->';
        
        $html = str_replace('{{CTA_SECTION}}', $cta_html, $html);
    } else {
        // Remove CTA section placeholder
        $html = str_replace('{{CTA_SECTION}}', '', $html);
    }
    
    return $html;
}
add_shortcode('td_hero', 'td_hero_shortcode');

/**
 * CTA Section Shortcode
 * 
 * Displays a full-width call-to-action section with optional button
 * 
 * Usage:
 *   [td_cta title="Ready to Get Started?" subtitle="Create your profile today"]
 *   [td_cta title="Ready to Get Started?" subtitle="Create your profile today" cta_display="Get Started" cta_link="/register"]
 * 
 * @param array $atts Shortcode attributes
 *   - title (string) Required: Main heading text
 *   - subtitle (string) Required: Description text
 *   - cta_display (string) Optional: Button display text (if empty, no button shown)
 *   - cta_link (string) Optional: Button URL (default: #)
 * 
 * @since v3.7.4
 */
function td_cta_shortcode($atts) {
    $atts = shortcode_atts([
        'title' => '',
        'subtitle' => '',
        'cta_display' => '',
        'cta_link' => '#'
    ], $atts);
    
    // Validate required attributes
    if (empty($atts['title']) || empty($atts['subtitle'])) {
        error_log('TD Shortcode Error: td_cta requires title and subtitle attributes');
        return '<!-- CTA section requires title and subtitle -->';
    }
    
    // Load template
    $template_file = get_stylesheet_directory() . '/includes/cta-template.html';
    if (!file_exists($template_file)) {
        error_log('TD Shortcode Error: cta-template.html not found at ' . $template_file);
        return '<!-- CTA template file not found -->';
    }
    
    $html = file_get_contents($template_file);
    
    // Replace placeholders
    $html = str_replace('{{title}}', esc_html($atts['title']), $html);
    $html = str_replace('{{subtitle}}', esc_html($atts['subtitle']), $html);
    
    // Handle optional CTA button
    if (!empty($atts['cta_display'])) {
        $cta_html = '<!-- wp:buttons {"style":{"spacing":{"margin":{"top":"48px"}}},"layout":{"type":"flex","justifyContent":"center"}} -->' . "\n";
        $cta_html .= '    <div class="wp-block-buttons" style="margin-top:48px;display:flex;justify-content:center">' . "\n";
        $cta_html .= '        <!-- wp:button {"className":"is-style-fill"} -->' . "\n";
        $cta_html .= '        <div class="wp-block-button is-style-fill"><a class="wp-block-button__link wp-element-button" href="' . esc_url($atts['cta_link']) . '">' . esc_html($atts['cta_display']) . '</a></div>' . "\n";
        $cta_html .= '        <!-- /wp:button -->' . "\n";
        $cta_html .= '    </div>' . "\n";
        $cta_html .= '    <!-- /wp:buttons -->';
        
        $html = str_replace('{{CTA_SECTION}}', $cta_html, $html);
    } else {
        // Remove CTA section placeholder
        $html = str_replace('{{CTA_SECTION}}', '', $html);
    }
    
    return $html;
}
add_shortcode('td_cta', 'td_cta_shortcode');

/**
 * Custom page title filter for browser tab (SEO title)
 * Uses _custom_page_title meta field if set, otherwise uses default post_title
 * 
 * This allows pages to have different titles in:
 * - Navigation menus (uses post_title)
 * - Browser tab/bookmarks (uses _custom_page_title meta or post_title)
 */
add_filter('document_title_parts', function($title_parts) {
    if (is_singular()) {
        $post_id = get_the_ID();
        $custom_title = get_post_meta($post_id, '_custom_page_title', true);
        
        if (!empty($custom_title)) {
            $title_parts['title'] = $custom_title;
        }
    }
    
    return $title_parts;
}, 10, 1);
