-- Fix registration redirect from /welcome to About Us (home page)
-- After renaming Welcome page to About Us, registration was redirecting to 404
-- Set WPUM wp_login_signup_redirect to page 6 (About Us, also front page)
UPDATE wp_options 
SET option_value = REPLACE(
    option_value,
    '"wp_login_signup_redirect";N;',
    '"wp_login_signup_redirect";a:1:{i:0;s:1:"6";}'
)
WHERE option_name = 'wpum_settings'
AND option_value NOT LIKE '%wp_login_signup_redirect%';

-- If setting already exists (inserted via wp-cli), ensure it points to page 6
UPDATE wp_options
SET option_value = REPLACE(
    REPLACE(option_value, '"wp_login_signup_redirect";a:1:{i:0;s:', '"wp_login_signup_redirect";a:1:{i:0;s:1:"6'),
    'a:1:{i:0;s:2:"6";', 'a:1:{i:0;s:1:"6";'
)
WHERE option_name = 'wpum_settings'
AND option_value LIKE '%wp_login_signup_redirect%';
