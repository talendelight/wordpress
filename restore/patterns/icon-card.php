<?php
/**
 * Title: Icon Feature Card
 * Slug: blocksy-child/icon-card
 * Categories: cards, features
 * Description: Card with Font Awesome icon, title, and description
 */
?>

<!-- wp:group {"style":{"spacing":{"padding":{"top":"var:preset|spacing|48","right":"var:preset|spacing|48","bottom":"var:preset|spacing|48","left":"var:preset|spacing|48"}},"border":{"radius":"12px"},"dimensions":{"minHeight":"100%"}},"backgroundColor":"white","className":"is-style-card","layout":{"type":"constrained"}} -->
<div class="wp-block-group is-style-card has-white-background-color has-background" style="border-radius:12px;min-height:100%;padding-top:var(--wp--preset--spacing--48);padding-right:var(--wp--preset--spacing--48);padding-bottom:var(--wp--preset--spacing--48);padding-left:var(--wp--preset--spacing--48)">
    <!-- wp:html -->
    <div style="text-align:center;">
        <i class="fas fa-star" style="font-size:48px;color:#3498DB;display:block;margin-bottom:8px;"></i>
        <h3 style="font-size:24px;font-weight:700;color:#063970;margin:0;">Feature Title</h3>
    </div>
    <!-- /wp:html -->

    <!-- wp:paragraph {"align":"center","style":{"typography":{"fontSize":"14px"},"color":{"text":"#666666"}}} -->
    <p class="has-text-align-center has-text-color" style="font-size:14px;color:#666666">Your feature description goes here. Keep it concise and focused on the key benefit.</p>
    <!-- /wp:paragraph -->
</div>
<!-- /wp:group -->
