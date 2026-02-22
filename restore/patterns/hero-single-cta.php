<?php
/**
 * Title: Hero with Single CTA
 * Slug: blocksy-child/hero-single-cta
 * Categories: hero, header
 * Description: Full-width hero section with heading, description, and single call-to-action button
 */
?>

<!-- wp:group {"align":"full","style":{"spacing":{"padding":{"top":"var:preset|spacing|80","bottom":"var:preset|spacing|80"}}},"backgroundColor":"navy","textColor":"gray-off-white","layout":{"type":"constrained"}} -->
<div class="wp-block-group alignfull has-gray-off-white-color has-navy-background-color has-text-color has-background" style="padding-top:var(--wp--preset--spacing--80);padding-bottom:var(--wp--preset--spacing--80)">
    <!-- wp:heading {"textAlign":"center","level":1,"style":{"typography":{"fontSize":"48px","fontWeight":"700"}}} -->
    <h1 class="wp-block-heading has-text-align-center" style="font-size:48px;font-weight:700">Your Hero Headline Here</h1>
    <!-- /wp:heading -->

    <!-- wp:paragraph {"align":"center","style":{"typography":{"fontSize":"20px"},"spacing":{"margin":{"top":"var:preset|spacing|24","bottom":"var:preset|spacing|48"}}}} -->
    <p class="has-text-align-center" style="margin-top:var(--wp--preset--spacing--24);margin-bottom:var(--wp--preset--spacing--48);font-size:20px">Your hero description text goes here. Make it compelling and clear.</p>
    <!-- /wp:paragraph -->

    <!-- wp:buttons {"layout":{"type":"flex","justifyContent":"center"},"style":{"spacing":{"margin":{"top":"48px"}}}} -->
    <div class="wp-block-buttons" style="margin-top:48px">
        <!-- wp:button {"className":"is-style-fill"} -->
        <div class="wp-block-button is-style-fill"><a class="wp-block-button__link wp-element-button" href="#get-started">Get Started</a></div>
        <!-- /wp:button -->
    </div>
    <!-- /wp:buttons -->
</div>
<!-- /wp:group -->
