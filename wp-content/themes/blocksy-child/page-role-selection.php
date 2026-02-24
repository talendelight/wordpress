
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
            <option value="td_candidate">Candidate</option>
            <option value="td_employer">Employer</option>
            <option value="td_scout">Scout</option>
        </select>
        <div class="td-role-selection-buttons">
            <button type="button" id="td-role-next">Next</button>
        </div>
    </form>
    <script>
    document.getElementById('td-role-next').onclick = function() {
        var role = document.getElementById('td_user_role').value;
        if (!role) {
            alert('Please select a role.');
            return;
        }
        window.location.href = '<?php echo esc_url(site_url('/register-profile/')); ?>?td_user_role=' + encodeURIComponent(role);
    };
    </script>
    <div class="td-role-selection-links">
        <a href="<?php echo esc_url(site_url('/log-in/')); ?>" class="td-signin-link">Already have an account? Sign In &raquo;</a><br>
        <a href="<?php echo esc_url(site_url('/password-reset/')); ?>" class="td-lostpw-link">Lost your password?</a>
    </div>
</div>
<!-- Elementor-friendly: You can add Elementor sections/widgets above or below this block. -->
<style>
/* Role Selection Page Styles (Match Login Page) */
.td-role-selection-container { max-width: 500px; margin: 60px auto; padding: 40px; background: #fff; border-radius: 8px; box-shadow: 0 2px 10px rgba(0,0,0,0.08); }
.td-role-selection-container h2 { color: #063970; font-size: 32px; font-weight: 700; text-align: center; margin-bottom: 30px; }
.td-role-selection-container form { margin: 0; }
.td-role-selection-container label { color: #063970; font-size: 14px; font-weight: 600; margin-bottom: 8px; display: block; }
.td-role-selection-container select { width: 100%; padding: 14px 16px; min-height: 50px; border: 1px solid #E0E0E0; border-radius: 4px; font-size: 16px; line-height: 1.5; transition: border-color 0.3s ease; box-sizing: border-box; margin: 0; }
.td-role-selection-container select:focus { outline: none; border-color: #063970; box-shadow: 0 0 0 3px rgba(6, 57, 112, 0.1); }
.td-role-selection-buttons { margin-top: 24px; text-align: center; }
.td-role-selection-buttons button { display: inline-block; min-width: 180px; padding: 14px 30px; border-radius: 50px; border: none; font-size: 16px; font-weight: 600; cursor: pointer; transition: all 0.3s ease; }
.td-role-selection-buttons button#td-role-next { background: #063970; color: #FFFFFF; box-shadow: 0 2px 4px rgba(6, 57, 112, 0.3); }
.td-role-selection-buttons button#td-role-next:hover { background: #0062e3; box-shadow: 0 2px 4px rgba(0, 98, 227, 0.3); }
.td-role-selection-buttons button#td-role-next:active { transform: translateY(0); background: #2980B9; box-shadow: 0 2px 4px rgba(52, 152, 219, 0.3); }
.td-role-selection-links { margin-top: 20px; text-align: center; }
.td-role-selection-links a { color: #3498DB; text-decoration: none; font-size: 14px; transition: color 0.3s ease; display: inline-block; margin: 5px 0; }
.td-role-selection-links a:hover { color: #063970; text-decoration: underline; }
/* Responsive */
@media (max-width: 768px) { .td-role-selection-container { margin: 30px 20px; padding: 30px 20px; } .td-role-selection-container h2 { font-size: 28px; } }
</style>
<?php
get_footer();
