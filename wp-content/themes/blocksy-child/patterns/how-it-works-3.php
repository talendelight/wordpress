<?php
/**
 * Title: How It Works (3 Steps)
 * Slug: blocksy-child/how-it-works-3
 * Categories: features, process
 * Description: 3-column grid showing a process or workflow with numbered steps
 */
?>

<!-- wp:group {"align":"full","style":{"spacing":{"padding":{"top":"var:preset|spacing|80","bottom":"var:preset|spacing|80"}}},"backgroundColor":"white","layout":{"type":"constrained"}} -->
<div class="wp-block-group alignfull has-white-background-color has-background" style="padding-top:var(--wp--preset--spacing--80);padding-bottom:var(--wp--preset--spacing--80)">
    <!-- wp:heading {"textAlign":"center","level":2,"style":{"spacing":{"margin":{"bottom":"64px"}},"color":{"text":"#063970"}}} -->
    <h2 class="wp-block-heading has-text-align-center has-text-color" style="margin-bottom:64px;color:#063970">How It Works</h2>
    <!-- /wp:heading -->

    <!-- wp:columns {"align":"wide","style":{"spacing":{"blockGap":{"top":"var:preset|spacing|32","left":"var:preset|spacing|32"}}}} -->
    <div class="wp-block-columns alignwide" style="gap:32px;">
        <!-- wp:column -->
        <div class="wp-block-column">
            <!-- wp:group {"style":{"border":{"radius":"12px"},"spacing":{"padding":"48px"}},"backgroundColor":"gray-off-white","layout":{"type":"constrained"}} -->
            <div class="wp-block-group has-gray-off-white-background-color has-background" style="border-radius:12px;padding:48px">
                <!-- Step number and icon -->
                <div style="text-align:center;">
                    <div style="width:64px;height:64px;border-radius:50%;background-color:#3498DB;color:#FFFFFF;font-size:28px;font-weight:700;display:flex;align-items:center;justify-content:center;margin:0 auto 16px;">1</div>
                    <h3 style="font-size:24px;font-weight:700;color:#063970;margin:0 0 16px 0;">Step One Title</h3>
                </div>
                <!-- wp:paragraph {"align":"center","style":{"typography":{"fontSize":"14px"},"color":{"text":"#666666"}}} -->
                <p class="has-text-align-center has-text-color" style="color:#666666;font-size:14px">Description of the first step in your process.</p>
                <!-- /wp:paragraph -->
            </div>
            <!-- /wp:group -->
        </div>
        <!-- /wp:column -->

        <!-- wp:column -->
        <div class="wp-block-column">
            <!-- wp:group {"style":{"border":{"radius":"12px"},"spacing":{"padding":"48px"}},"backgroundColor":"gray-off-white","layout":{"type":"constrained"}} -->
            <div class="wp-block-group has-gray-off-white-background-color has-background" style="border-radius:12px;padding:48px">
                <!-- Step number and icon -->
                <div style="text-align:center;">
                    <div style="width:64px;height:64px;border-radius:50%;background-color:#3498DB;color:#FFFFFF;font-size:28px;font-weight:700;display:flex;align-items:center;justify-content:center;margin:0 auto 16px;">2</div>
                    <h3 style="font-size:24px;font-weight:700;color:#063970;margin:0 0 16px 0;">Step Two Title</h3>
                </div>
                <!-- wp:paragraph {"align":"center","style":{"typography":{"fontSize":"14px"},"color":{"text":"#666666"}}} -->
                <p class="has-text-align-center has-text-color" style="color:#666666;font-size:14px">Description of the second step in your process.</p>
                <!-- /wp:paragraph -->
            </div>
            <!-- /wp:group -->
        </div>
        <!-- /wp:column -->

        <!-- wp:column -->
        <div class="wp-block-column">
            <!-- wp:group {"style":{"border":{"radius":"12px"},"spacing":{"padding":"48px"}},"backgroundColor":"gray-off-white","layout":{"type":"constrained"}} -->
            <div class="wp-block-group has-gray-off-white-background-color has-background" style="border-radius:12px;padding:48px">
                <!-- Step number and icon -->
                <div style="text-align:center;">
                    <div style="width:64px;height:64px;border-radius:50%;background-color:#3498DB;color:#FFFFFF;font-size:28px;font-weight:700;display:flex;align-items:center;justify-content:center;margin:0 auto 16px;">3</div>
                    <h3 style="font-size:24px;font-weight:700;color:#063970;margin:0 0 16px 0;">Step Three Title</h3>
                </div>
                <!-- wp:paragraph {"align":"center","style":{"typography":{"fontSize":"14px"},"color":{"text":"#666666"}}} -->
                <p class="has-text-align-center has-text-color" style="color:#666666;font-size:14px">Description of the third step in your process.</p>
                <!-- /wp:paragraph -->
            </div>
            <!-- /wp:group -->
        </div>
        <!-- /wp:column -->
    </div>
    <!-- /wp:columns -->
</div>
<!-- /wp:group -->
