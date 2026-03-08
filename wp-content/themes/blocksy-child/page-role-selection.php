
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
    <h2>Who are you?</h2>
    <form id="td-role-selection-form">
        <label for="td_user_role">I am</label>
        <select name="td_user_role" id="td_user_role" required>
            <option value="">-- Select Profile --</option>
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
</div>
<!-- Elementor-friendly: You can add Elementor sections/widgets above or below this block. -->
<style>
/* Role Selection Page Styles - Design Token Based */
.td-role-selection-container {
    max-width: 500px;
    margin: var(--space-3xl) auto;
    padding: var(--space-2xl);
    background: var(--color-white);
    border-radius: var(--border-radius-sm);
    box-shadow: var(--shadow-md);
}

.td-role-selection-container h2 {
    color: var(--color-navy);
    font-size: var(--font-size-3xl);
    font-weight: 700;
    text-align: center;
    margin-bottom: var(--space-xl);
}

.td-role-selection-container form {
    margin: 0;
}

.td-role-selection-container label {
    color: var(--color-navy);
    font-size: var(--font-size-sm);
    font-weight: 600;
    margin-bottom: var(--space-sm);
    display: block;
}

.td-role-selection-container select {
    width: 100%;
    padding: 12px 16px;
    height: 50px;
    border: 1px solid var(--input-border-default);
    border-radius: var(--border-radius-sm);
    font-size: var(--font-size-base);
    line-height: 1.5;
    transition: border-color 0.3s ease, box-shadow 0.3s ease;
    box-sizing: border-box;
    margin: 0;
}

.td-role-selection-container select:focus {
    outline: none;
    border-color: var(--input-border-focus);
    box-shadow: var(--focus-ring);
}

.td-role-selection-buttons {
    margin-top: var(--space-lg);
    text-align: center;
}

.td-role-selection-buttons button {
    display: inline-block;
    min-width: 180px;
    padding: 14px var(--space-xl);
    border-radius: var(--border-radius-pill);
    border: none;
    font-size: var(--font-size-base);
    font-weight: 600;
    cursor: pointer;
    transition: all 0.3s ease;
}

.td-role-selection-buttons button#td-role-next {
    background: var(--color-navy);
    color: var(--color-white);
}

.td-role-selection-buttons button#td-role-next:hover {
    background: var(--color-navy-hover);
    transform: translateY(-1px);
}

.td-role-selection-buttons button#td-role-next:active {
    transform: translateY(0);
    background: var(--color-navy-hover);
}

/* Responsive */
@media (max-width: 768px) {
    .td-role-selection-container {
        margin: var(--space-xl) var(--space-md);
        padding: var(--space-xl) var(--space-md);
    }
    
    .td-role-selection-container h2 {
        font-size: var(--font-size-2xl);
    }
}
</style>
<?php
get_footer();
