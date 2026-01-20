<?php
/**
 * Deploy custom CSS to WordPress Additional CSS (theme mods)
 */

$css_file = getenv('HOME') . '/custom.css';

if (!file_exists($css_file)) {
    echo "Error: CSS file not found at $css_file\n";
    exit(1);
}

$css_content = file_get_contents($css_file);

if (empty($css_content)) {
    echo "Error: CSS file is empty\n";
    exit(1);
}

// Get current theme mods
$theme_slug = get_option('stylesheet'); // Active theme slug
$mods = get_theme_mods();

// Update custom_css in theme mods
$mods['custom_css'] = $css_content;

// Save theme mods
update_option("theme_mods_$theme_slug", $mods);

echo "✓ Custom CSS deployed successfully\n";
echo "Theme: $theme_slug\n";
echo "CSS length: " . strlen($css_content) . " bytes\n";
