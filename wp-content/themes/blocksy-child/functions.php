<?php
// Redirect default register page to custom role selection page
add_action('template_redirect', function() {
    if (is_page('register')) {
        wp_redirect(site_url('/select-role/'));
        exit;
    }
});

// Redirect WordPress logout to Welcome page
add_action('wp_logout', function() {
    wp_redirect(site_url('/welcome/'));
    exit;
});
