<?php
/**
 * Title: Status Alert (Error)
 * Slug: blocksy-child/alert-error
 * Categories: alerts, notifications
 * Description: Error alert message with icon
 */
?>

<!-- wp:group {"style":{"border":{"radius":"8px","width":"1px","color":"#dc3545"},"spacing":{"padding":"16px 24px"},"color":{"background":"#f8d7da"}},"layout":{"type":"flex","flexWrap":"nowrap"}} -->
<div class="wp-block-group has-border-color has-background" style="border-color:#dc3545;border-width:1px;border-radius:8px;background-color:#f8d7da;padding:16px 24px">
    <!-- wp:html -->
    <i class="fas fa-times-circle" style="font-size:20px;color:#dc3545;margin-right:12px;"></i>
    <!-- /wp:html -->

    <!-- wp:paragraph {"style":{"color":{"text":"#721c24"},"typography":{"fontSize":"14px"},"spacing":{"margin":{"top":"0","bottom":"0"}}}} -->
    <p class="has-text-color" style="color:#721c24;font-size:14px;margin-top:0;margin-bottom:0"><strong>Error!</strong> Something went wrong. Please try again.</p>
    <!-- /wp:paragraph -->
</div>
<!-- /wp:group -->
