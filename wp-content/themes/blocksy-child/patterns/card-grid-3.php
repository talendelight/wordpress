<?php
/**
 * Title: Card Grid - 3 Columns
 * Slug: blocksy-child/card-grid-3
 * Categories: cards, columns
 * Description: Three equal-width cards in a single row, perfect for "How it Works" or feature sections
 */
?>

<!-- wp:group {"align":"full","style":{"spacing":{"padding":{"top":"var:preset|spacing|80","bottom":"var:preset|spacing|80"}}},"backgroundColor":"gray-off-white","layout":{"type":"constrained"}} -->
<div class="wp-block-group alignfull has-gray-off-white-background-color has-background" style="padding-top:var(--wp--preset--spacing--80);padding-bottom:var(--wp--preset--spacing--80)">
    <!-- wp:heading {"textAlign":"center","level":2,"style":{"spacing":{"margin":{"bottom":"64px"}},"color":{"text":"#063970"}}} -->
    <h2 class="wp-block-heading has-text-align-center has-text-color" style="margin-bottom:64px;color:#063970">Section Title</h2>
    <!-- /wp:heading -->

    <!-- wp:columns {"align":"wide","style":{"spacing":{"blockGap":{"top":"var:preset|spacing|32","left":"var:preset|spacing|32"},"margin":{"top":"0","bottom":"0"}}}} -->
    <div class="wp-block-columns alignwide" style="margin-top:0;margin-bottom:0">
        <!-- wp:column -->
        <div class="wp-block-column">
            <!-- wp:group {"style":{"spacing":{"padding":{"top":"var:preset|spacing|48","right":"var:preset|spacing|48","bottom":"var:preset|spacing|48","left":"var:preset|spacing|48"}},"border":{"radius":"12px"},"dimensions":{"minHeight":"100%"}},"backgroundColor":"white","className":"is-style-card","layout":{"type":"constrained"}} -->
            <div class="wp-block-group is-style-card has-white-background-color has-background" style="border-radius:12px;min-height:100%;padding-top:var(--wp--preset--spacing--48);padding-right:var(--wp--preset--spacing--48);padding-bottom:var(--wp--preset--spacing--48);padding-left:var(--wp--preset--spacing--48)">
                <!-- wp:html -->
                <div style="text-align:center;">
                    <i class="fas fa-check-circle" style="font-size:48px;color:#3498DB;display:block;margin-bottom:8px;"></i>
                    <h3 style="font-size:24px;font-weight:700;color:#063970;margin:0;">Step 1</h3>
                </div>
                <!-- /wp:html -->

                <!-- wp:paragraph {"align":"center","style":{"typography":{"fontSize":"14px"},"color":{"text":"#666666"}}} -->
                <p class="has-text-align-center has-text-color" style="color:#666666;font-size:14px">Description of the first step or feature goes here.</p>
                <!-- /wp:paragraph -->
            </div>
            <!-- /wp:group -->
        </div>
        <!-- /wp:column -->

        <!-- wp:column -->
        <div class="wp-block-column">
            <!-- wp:group {"style":{"spacing":{"padding":{"top":"var:preset|spacing|48","right":"var:preset|spacing|48","bottom":"var:preset|spacing|48","left":"var:preset|spacing|48"}},"border":{"radius":"12px"},"dimensions":{"minHeight":"100%"}},"backgroundColor":"white","className":"is-style-card","layout":{"type":"constrained"}} -->
            <div class="wp-block-group is-style-card has-white-background-color has-background" style="border-radius:12px;min-height:100%;padding-top:var(--wp--preset--spacing--48);padding-right:var(--wp--preset--spacing--48);padding-bottom:var(--wp--preset--spacing--48);padding-left:var(--wp--preset--spacing--48)">
                <!-- wp:html -->
                <div style="text-align:center;">
                    <i class="fas fa-check-circle" style="font-size:48px;color:#3498DB;display:block;margin-bottom:8px;"></i>
                    <h3 style="font-size:24px;font-weight:700;color:#063970;margin:0;">Step 2</h3>
                </div>
                <!-- /wp:html -->

                <!-- wp:paragraph {"align":"center","style":{"typography":{"fontSize":"14px"},"color":{"text":"#666666"}}} -->
                <p class="has-text-align-center has-text-color" style="color:#666666;font-size:14px">Description of the second step or feature goes here.</p>
                <!-- /wp:paragraph -->
            </div>
            <!-- /wp:group -->
        </div>
        <!-- /wp:column -->

        <!-- wp:column -->
        <div class="wp-block-column">
            <!-- wp:group {"style":{"spacing":{"padding":{"top":"var:preset|spacing|48","right":"var:preset|spacing|48","bottom":"var:preset|spacing|48","left":"var:preset|spacing|48"}},"border":{"radius":"12px"},"dimensions":{"minHeight":"100%"}},"backgroundColor":"white","className":"is-style-card","layout":{"type":"constrained"}} -->
            <div class="wp-block-group is-style-card has-white-background-color has-background" style="border-radius:12px;min-height:100%;padding-top:var(--wp--preset--spacing--48);padding-right:var(--wp--preset--spacing--48);padding-bottom:var(--wp--preset--spacing--48);padding-left:var(--wp--preset--spacing--48)">
                <!-- wp:html -->
                <div style="text-align:center;">
                    <i class="fas fa-check-circle" style="font-size:48px;color:#3498DB;display:block;margin-bottom:8px;"></i>
                    <h3 style="font-size:24px;font-weight:700;color:#063970;margin:0;">Step 3</h3>
                </div>
                <!-- /wp:html -->

                <!-- wp:paragraph {"align":"center","style":{"typography":{"fontSize":"14px"},"color":{"text":"#666666"}}} -->
                <p class="has-text-align-center has-text-color" style="color:#666666;font-size:14px">Description of the third step or feature goes here.</p>
                <!-- /wp:paragraph -->
            </div>
            <!-- /wp:group -->
        </div>
        <!-- /wp:column -->
    </div>
    <!-- /wp:columns -->
</div>
<!-- /wp:group -->
