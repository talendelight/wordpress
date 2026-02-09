<?php
/**
 * Title: Footer - Trust Badges
 * Slug: blocksy-child/footer-trust-badges
 * Categories: footer
 * Description: Footer section with 4 trust badges (GDPR, Secure, Equal Opportunity, EU Markets)
 */
?>

<!-- Footer Trust Badges Section -->
<!-- wp:group {"align":"full","style":{"spacing":{"padding":{"top":"var:preset|spacing|48","bottom":"var:preset|spacing|48"}}},"backgroundColor":"gray-light","layout":{"type":"constrained"}} -->
<div class="wp-block-group alignfull has-gray-light-background-color has-background" style="padding-top:var(--wp--preset--spacing--48);padding-bottom:var(--wp--preset--spacing--48)">
    <!-- wp:columns {"verticalAlignment":"center","style":{"spacing":{"blockGap":{"top":"var:preset|spacing|24","left":"var:preset|spacing|24"}}}} -->
    <div class="wp-block-columns are-vertically-aligned-center">
        <!-- wp:column {"verticalAlignment":"center"} -->
        <div class="wp-block-column is-vertically-aligned-center">
            <!-- wp:paragraph {"align":"center","style":{"typography":{"fontSize":"14px","fontWeight":"600"}}} -->
            <p class="has-text-align-center" style="font-size:14px;font-weight:600">🔒 GDPR Compliant</p>
            <!-- /wp:paragraph -->
        </div>
        <!-- /wp:column -->

        <!-- wp:column {"verticalAlignment":"center"} -->
        <div class="wp-block-column is-vertically-aligned-center">
            <!-- wp:paragraph {"align":"center","style":{"typography":{"fontSize":"14px","fontWeight":"600"}}} -->
            <p class="has-text-align-center" style="font-size:14px;font-weight:600">✓ Secure &amp; Reliable</p>
            <!-- /wp:paragraph -->
        </div>
        <!-- /wp:column -->

        <!-- wp:column {"verticalAlignment":"center"} -->
        <div class="wp-block-column is-vertically-aligned-center">
            <!-- wp:paragraph {"align":"center","style":{"typography":{"fontSize":"14px","fontWeight":"600"}}} -->
            <p class="has-text-align-center" style="font-size:14px;font-weight:600">🤝 Equal Opportunity</p>
            <!-- /wp:paragraph -->
        </div>
        <!-- /wp:column -->

        <!-- wp:column {"verticalAlignment":"center"} -->
        <div class="wp-block-column is-vertically-aligned-center">
            <!-- wp:html -->
            <div style="text-align:center;font-size:14px;font-weight:600;">
                <img src="/wp-content/themes/blocksy-child/assets/images/eu-logo.svg" alt="European Union" style="height:20px;vertical-align:middle;margin-right:8px;"/>Serving EU Markets
            </div>
            <!-- /wp:html -->
        </div>
        <!-- /wp:column -->
    </div>
    <!-- /wp:columns -->
</div>
<!-- /wp:group -->
