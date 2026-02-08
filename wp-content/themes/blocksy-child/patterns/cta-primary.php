<?php
/**
 * Title: Primary CTA Band
 * Slug: blocksy-child/cta-primary
 * Categories: call-to-action, cta
 * Description: Full-width call-to-action band with heading and button
 */
?>

<!-- wp:group {"align":"full","style":{"spacing":{"padding":{"top":"var:preset|spacing|80","bottom":"var:preset|spacing|80"}}},"backgroundColor":"blue","textColor":"white","layout":{"type":"constrained"}} -->
<div class="wp-block-group alignfull has-white-color has-blue-background-color has-text-color has-background" style="padding-top:var(--wp--preset--spacing--80);padding-bottom:var(--wp--preset--spacing--80)">
    <!-- wp:heading {"textAlign":"center","level":2,"style":{"typography":{"fontSize":"36px","fontWeight":"700"}}} -->
    <h2 class="wp-block-heading has-text-align-center" style="font-size:36px;font-weight:700">Ready to get started?</h2>
    <!-- /wp:heading -->

    <!-- wp:paragraph {"align":"center","style":{"spacing":{"margin":{"top":"var:preset|spacing|24","bottom":"var:preset|spacing|48"}}}} -->
    <p class="has-text-align-center" style="margin-top:var(--wp--preset--spacing--24);margin-bottom:var(--wp--preset--spacing--48)">Join thousands of users already using our platform.</p>
    <!-- /wp:paragraph -->

    <!-- wp:buttons {"layout":{"type":"flex","justifyContent":"center"}} -->
    <div class="wp-block-buttons">
        <!-- wp:button {"backgroundColor":"white","textColor":"navy","className":"is-style-fill"} -->
        <div class="wp-block-button is-style-fill"><a class="wp-block-button__link has-navy-color has-white-background-color has-text-color has-background wp-element-button" href="/register/">Get Started Now</a></div>
        <!-- /wp:button -->
    </div>
    <!-- /wp:buttons -->
</div>
<!-- /wp:group -->
