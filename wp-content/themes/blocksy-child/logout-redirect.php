<?php
// Redirect WordPress logout to Welcome page
add_action('wp_logout', function() {
    wp_redirect(site_url('/welcome/'));
    exit;
});
