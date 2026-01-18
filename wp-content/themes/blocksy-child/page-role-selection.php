
<?php
/*
 * Template Name: Role Selection Page
 * Description: Displays a dropdown for user to select role before registration.
 * Elementor-friendly: Yes
 */
if (!defined('ABSPATH')) {
    exit;
}
get_header();
?>
<div id="td-role-selection-elementor" class="td-role-selection-container">
    <h2>Select Your Role</h2>
    <form id="td-role-selection-form">
        <label for="td_user_role">Choose your role:</label>
        <select name="td_user_role" id="td_user_role" required>
            <option value="">-- Select Role --</option>
            <option value="candidate">Candidate</option>
            <option value="employer">Employer</option>
            <option value="scout">Scout</option>
        </select>
        <div class="td-role-selection-buttons">
            <button type="button" id="td-role-back">Back</button>
            <button type="button" id="td-role-next">Next</button>
        </div>
    </form>
    <script>
    document.getElementById('td-role-back').onclick = function() {
        window.location.href = '<?php echo esc_url(site_url('/welcome/')); ?>';
    };
    document.getElementById('td-role-next').onclick = function() {
        var role = document.getElementById('td_user_role').value;
        if (!role) {
            alert('Please select a role.');
            return;
        }
        window.location.href = '<?php echo esc_url(site_url('/register-profile/')); ?>?td_user_role=' + encodeURIComponent(role);
    };
    </script>
    <div class="td-role-selection-links" style="margin-top:24px;text-align:center;">
        <a href="<?php echo esc_url(site_url('/log-in/')); ?>" class="td-signin-link">Already have an account? Sign In &raquo;</a><br>
        <a href="<?php echo esc_url(site_url('/password-reset/')); ?>" class="td-lostpw-link">Lost your password?</a>
    </div>
</div>
<!-- Elementor-friendly: You can add Elementor sections/widgets above or below this block. -->
<style>
/* Role Selection Page Styles (Elementor-friendly) */
.td-role-selection-container { max-width: 400px; margin: 40px auto; padding: 32px; background: #fff; border-radius: 8px; box-shadow: 0 2px 12px rgba(0,0,0,0.08); }
.td-role-selection-buttons { display: flex; justify-content: space-between; margin-top: 24px; }
.td-role-selection-buttons button { min-width: 100px; padding: 8px 16px; border-radius: 4px; border: none; background: #1e88e5; color: #fff; font-weight: 600; cursor: pointer; transition: background 0.2s; }
.td-role-selection-buttons button[type="button"] { background: #888; }
.td-role-selection-buttons button:hover { opacity: 0.9; }
</style>
<?php
get_footer();
