<?php
/**
 * The template for displaying the footer
 *
 * Override parent Blocksy theme to add custom copyright text
 *
 * @package Blocksy-Child
 */

blocksy_after_current_template();
do_action('blocksy:content:bottom');

?>
        </main>

        <?php
                do_action('blocksy:content:after');
                
                // Custom copyright footer for HireAccord
                // Replaces default Blocksy footer to show HireAccord branding
                $copyright_text = get_theme_mod('copyright_text', '&copy; {current_year} HireAccord &mdash; A brand of Lochness Technologies LLP. All rights reserved.');
                // Replace {current_year} placeholder
                $copyright_text = str_replace('{current_year}', date('Y'), $copyright_text);
                // Decode HTML entities (&copy; → ©, &mdash; → —)
                $copyright_text = html_entity_decode($copyright_text, ENT_QUOTES | ENT_HTML5, 'UTF-8');
                ?>
                <footer class="td-custom-copyright" style="background: #f8f9fa; padding: 24px 0 20px; text-align: center; border-top: 1px solid #e0e0e0; margin-top: 0;">
                    <div class="container" style="max-width: 1200px; margin: 0 auto; padding: 0 20px;">
                        <!-- Legal Links -->
                        <div class="legal-links" style="margin-bottom: 12px;">
                            <a href="/privacy-policy/" target="_blank" style="color: #063970; text-decoration: none; font-size: 14px; margin: 0 8px;">Privacy Policy</a>
                            <span style="color: #A0AEC0;">|</span>
                            <a href="/cookie-policy/" target="_blank" style="color: #063970; text-decoration: none; font-size: 14px; margin: 0 8px;">Cookie Policy</a>
                            <span style="color: #A0AEC0;">|</span>
                            <a href="/terms-conditions/" target="_blank" style="color: #063970; text-decoration: none; font-size: 14px; margin: 0 8px;">Terms &amp; Conditions</a>
                        </div>
                        <!-- Copyright Text -->
                        <p style="margin: 0; color: #4A5568; font-size: 14px;">
                            <?php echo esc_html($copyright_text); ?>
                        </p>
                    </div>
                </footer>
                <?php
        ?>
</div>

<?php wp_footer(); ?>

</body>
</html>
