<?php
/**
 * Deployment Helper - ID Mapping and Replacement
 * 
 * Strategy: Use slugs to lookup IDs dynamically, then replace IDs in Elementor data
 * 
 * Usage: wp eval-file deploy-id-mapper.php -- --page-slug=register-profile --form-slug=person-registration-form
 */

// Parse command line arguments
$args = array();
foreach ($argv as $arg) {
    if (strpos($arg, '--') === 0) {
        $parts = explode('=', substr($arg, 2), 2);
        if (count($parts) === 2) {
            $args[$parts[0]] = $parts[1];
        }
    }
}

// Load manifest
$manifest_path = getcwd() . '/../../../infra/shared/elementor-manifest.json';
if (!file_exists($manifest_path)) {
    echo "Error: Manifest not found at $manifest_path\n";
    exit(1);
}

$manifest = json_decode(file_get_contents($manifest_path), true);
if (!$manifest) {
    echo "Error: Invalid manifest JSON\n";
    exit(1);
}

/**
 * Lookup ID by slug
 */
function lookup_id_by_slug($slug, $post_type = 'page') {
    $posts = get_posts(array(
        'post_type' => $post_type,
        'name' => $slug,
        'posts_per_page' => 1,
        'fields' => 'ids'
    ));
    
    return !empty($posts) ? $posts[0] : null;
}

/**
 * Build ID mapping from manifest
 */
function build_id_map($manifest) {
    $map = array(
        'pages' => array(),
        'forms' => array()
    );
    
    // Map pages
    if (isset($manifest['pages'])) {
        foreach ($manifest['pages'] as $page) {
            if (isset($page['slug'])) {
                $prod_id = lookup_id_by_slug($page['slug'], 'page');
                if ($prod_id) {
                    $map['pages'][$page['slug']] = array(
                        'local_id' => $page['local_id'],
                        'prod_id' => $prod_id,
                        'name' => $page['name']
                    );
                }
            }
        }
    }
    
    // Map forms
    if (isset($manifest['forms'])) {
        foreach ($manifest['forms'] as $form) {
            if (isset($form['slug'])) {
                $prod_id = lookup_id_by_slug($form['slug'], $form['type']);
                if ($prod_id) {
                    $map['forms'][$form['slug']] = array(
                        'local_id' => $form['local_id'],
                        'prod_id' => $prod_id,
                        'name' => $form['name']
                    );
                }
            }
        }
    }
    
    return $map;
}

/**
 * Replace IDs in Elementor data
 */
function replace_ids_in_elementor_data($page_slug, $form_slug_map) {
    $page_id = lookup_id_by_slug($page_slug, 'page');
    if (!$page_id) {
        echo "Error: Page not found with slug: $page_slug\n";
        return false;
    }
    
    $elementor_data = get_post_meta($page_id, '_elementor_data', true);
    if (!$elementor_data) {
        echo "Warning: No Elementor data found for page: $page_slug\n";
        return false;
    }
    
    $data_array = json_decode($elementor_data, true);
    if (!$data_array) {
        echo "Error: Invalid Elementor data JSON\n";
        return false;
    }
    
    $modified = false;
    $replacements = array();
    
    // Walk through Elementor data and replace form IDs
    array_walk_recursive($data_array, function(&$value, $key) use ($form_slug_map, &$modified, &$replacements) {
        // Replace in shortcodes like [forminator_form id="123"]
        if (is_string($value) && strpos($value, 'forminator_form') !== false) {
            foreach ($form_slug_map as $slug => $ids) {
                $pattern = '/forminator_form\s+id=\\\\"(\d+)\\\\"/';
                if (preg_match($pattern, $value, $matches)) {
                    $old_id = $matches[1];
                    $new_id = $ids['prod_id'];
                    $value = preg_replace(
                        '/forminator_form\s+id=\\\\"' . $old_id . '\\\\"/',
                        'forminator_form id="' . $new_id . '"',
                        $value
                    );
                    $modified = true;
                    $replacements[] = "Form ID: $old_id → $new_id (slug: $slug)";
                }
            }
        }
        
        // Replace in Gutenberg blocks like {"module_id":"123"}
        if ($key === 'module_id' && is_numeric($value)) {
            foreach ($form_slug_map as $slug => $ids) {
                if ($value == $ids['local_id']) {
                    $value = (string)$ids['prod_id'];
                    $modified = true;
                    $replacements[] = "Module ID: {$ids['local_id']} → {$ids['prod_id']} (slug: $slug)";
                }
            }
        }
    });
    
    if ($modified) {
        $new_data = json_encode($data_array);
        update_post_meta($page_id, '_elementor_data', $new_data);
        echo "Success: Updated page $page_slug (ID: $page_id)\n";
        echo "Replacements made:\n";
        foreach ($replacements as $replacement) {
            echo "  - $replacement\n";
        }
        return true;
    } else {
        echo "No replacements needed for page: $page_slug\n";
        return false;
    }
}

// Main execution
echo "=== Deployment ID Mapper ===\n\n";
echo "Building ID map from manifest...\n";
$id_map = build_id_map($manifest);

echo "\nCurrent ID Mappings:\n";
echo "Pages:\n";
foreach ($id_map['pages'] as $slug => $data) {
    echo "  $slug: {$data['local_id']} → {$data['prod_id']}\n";
}
echo "\nForms:\n";
foreach ($id_map['forms'] as $slug => $data) {
    echo "  $slug: {$data['local_id']} → {$data['prod_id']}\n";
}

// If specific page and form requested, do the replacement
if (isset($args['page-slug']) && isset($args['form-slug'])) {
    $page_slug = $args['page-slug'];
    $form_slug = $args['form-slug'];
    
    echo "\n\nReplacing IDs in page: $page_slug\n";
    echo "Using form: $form_slug\n\n";
    
    if (!isset($id_map['forms'][$form_slug])) {
        echo "Error: Form slug not found in ID map: $form_slug\n";
        exit(1);
    }
    
    $form_map = array($form_slug => $id_map['forms'][$form_slug]);
    $success = replace_ids_in_elementor_data($page_slug, $form_map);
    
    exit($success ? 0 : 1);
} else {
    echo "\n\nTo perform ID replacement, run:\n";
    echo "wp eval-file deploy-id-mapper.php -- --page-slug=PAGE_SLUG --form-slug=FORM_SLUG\n";
    exit(0);
}
