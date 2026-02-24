(function() {
    'use strict';
    
    // DEBUG: Confirm script is loading
    console.log('✅ registration-form.js loaded successfully');
    
    // Floating message function
    function showFloatingMessage(message, type) {
        var messageEl = document.getElementById('td-floating-message');
        messageEl.textContent = message;
        messageEl.className = type + ' show';
        
        // Hide after 2 seconds and redirect on success
        setTimeout(function() {
            messageEl.classList.remove('show');
            if (type === 'success') {
                // Redirect to Welcome page after animation completes
                setTimeout(function() {
                    window.location.href = '/welcome/';
                }, 300);
            }
        }, 2000);
    }
    
    // Get role from URL parameter and populate hidden field
    function getUrlParameter(name) {
        name = name.replace(/[\[]/, '\\[').replace(/[\]]/, '\\]');
        var regex = new RegExp('[\\?&]' + name + '=([^&#]*)');
        var results = regex.exec(location.search);
        return results === null ? '' : decodeURIComponent(results[1].replace(/\+/g, ' '));
    }
    
    // Show/hide loading spinner
    function showLoadingSpinner(show) {
        var form = document.getElementById('td-registration-form');
        if (!form) return;
        
        var spinner = form.querySelector('.nonce-loading-spinner');
        if (!spinner) {
            spinner = document.createElement('div');
            spinner.className = 'nonce-loading-spinner';
            spinner.style.cssText = 'position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); background: rgba(255,255,255,0.95); padding: 20px; border-radius: 8px; box-shadow: 0 2px 8px rgba(0,0,0,0.1); z-index: 1000; display: none;';
            spinner.innerHTML = '<div style="text-align: center;"><div style="border: 3px solid #f3f3f3; border-top: 3px solid #3498db; border-radius: 50%; width: 40px; height: 40px; animation: spin 1s linear infinite; margin: 0 auto 10px;"></div><div style="color: #666; font-size: 14px;">Loading security token...</div></div>';
            
            // Add animation keyframes
            if (!document.getElementById('spinner-animation')) {
                var style = document.createElement('style');
                style.id = 'spinner-animation';
                style.textContent = '@keyframes spin { 0% { transform: rotate(0deg); } 100% { transform: rotate(360deg); } }';
                document.head.appendChild(style);
            }
            
            form.appendChild(spinner);
        }
        
        spinner.style.display = show ? 'block' : 'none';
        
        // Disable form during loading
        var submitBtn = form.querySelector('.submit-btn');
        if (submitBtn) {
            submitBtn.disabled = show;
        }
    }
    
    // Fetch registration nonce from server with retry logic
    function fetchRegistrationNonce(attempt, maxAttempts) {
        attempt = attempt || 1;
        maxAttempts = maxAttempts || 3;
        
        console.log('🎯 fetchRegistrationNonce called (attempt ' + attempt + '/' + maxAttempts + ')');
        
        if (attempt === 1) {
            showLoadingSpinner(true);
        }
        
        console.log('📡 Creating XHR request to /wp-admin/admin-ajax.php');
        var xhr = new XMLHttpRequest();
        xhr.open('POST', '/wp-admin/admin-ajax.php', true);
        xhr.setRequestHeader('Content-Type', 'application/x-www-form-urlencoded');
        
        xhr.onload = function() {
            console.log('📥 XHR onload - Status:', xhr.status);
            console.log('📥 Response text:', xhr.responseText);
            if (xhr.status === 200) {
                try {
                    var response = JSON.parse(xhr.responseText);
                    if (response.success && response.data.nonce) {
                        var nonceField = document.getElementById('td_registration_nonce');
                        if (nonceField) {
                            nonceField.value = response.data.nonce;
                            console.log('Registration nonce loaded successfully (attempt ' + attempt + ')');
                            showLoadingSpinner(false);
                        }
                    } else {
                        throw new Error('Invalid nonce response');
                    }
                } catch (e) {
                    console.error('Failed to parse nonce response:', e);
                    retryFetch(attempt, maxAttempts);
                }
            } else {
                console.error('HTTP error fetching nonce:', xhr.status);
                retryFetch(attempt, maxAttempts);
            }
        };
        
        xhr.onerror = function() {
            console.error('❌ Network error fetching nonce');
            retryFetch(attempt, maxAttempts);
        };
        
        xhr.ontimeout = function() {
            console.error('⏱️ Timeout fetching nonce (5s limit)');
            retryFetch(attempt, maxAttempts);
        };
        
        xhr.timeout = 5000; // 5 second timeout
        console.log('🚀 Sending XHR request with action=td_get_registration_nonce');
        xhr.send('action=td_get_registration_nonce');
        
        function retryFetch(currentAttempt, max) {
            if (currentAttempt < max) {
                var delay = Math.pow(2, currentAttempt) * 1000; // Exponential backoff: 2s, 4s, 8s
                console.log('Retrying nonce fetch in ' + (delay / 1000) + ' seconds... (attempt ' + (currentAttempt + 1) + '/' + max + ')');
                setTimeout(function() {
                    fetchRegistrationNonce(currentAttempt + 1, max);
                }, delay);
            } else {
                showLoadingSpinner(false);
                showFloatingMessage('Unable to load security token. Please refresh the page and try again.', 'error');
                console.error('Failed to fetch nonce after ' + max + ' attempts');
            }
        }
    }
    
    // Initialize on DOM ready
    console.log('🔍 Document ready state:', document.readyState);
    if (document.readyState === 'loading') {
        console.log('⏳ Waiting for DOMContentLoaded...');
        document.addEventListener('DOMContentLoaded', init);
    } else {
        console.log('⚡ DOM already loaded, initializing immediately');
        init();
    }
    
    function init() {
        console.log('🚀 init() called');
        var form = document.getElementById('td-registration-form');
        console.log('📝 Form element found:', !!form);
        if (!form) {
            console.error('❌ Form with id="td-registration-form" not found!');
            return;
        }
        
        // Create hidden fields dynamically if they don't exist
        // This is needed because WordPress HTML blocks may strip them out
        var roleInput = document.getElementById('td_user_role');
        if (!roleInput) {
            console.log('⚠️ Role input field missing, creating dynamically...');
            roleInput = document.createElement('input');
            roleInput.type = 'hidden';
            roleInput.name = 'td_user_role';
            roleInput.id = 'td_user_role';
            roleInput.value = '';
            form.insertBefore(roleInput, form.firstChild);
            console.log('✅ Created td_user_role hidden field');
        }
        
        var actionInput = document.getElementById('action');
        if (!actionInput || actionInput.value !== 'td_process_registration') {
            console.log('⚠️ Action input field missing, creating dynamically...');
            if (!actionInput) {
                actionInput = document.createElement('input');
                actionInput.type = 'hidden';
                actionInput.name = 'action';
                actionInput.id = 'action';
                form.insertBefore(actionInput, form.firstChild);
            }
            actionInput.value = 'td_process_registration';
            console.log('✅ Created/updated action hidden field');
        }
        
        console.log('🔐 Calling fetchRegistrationNonce()...');
        // Fetch nonce via AJAX on page load
        fetchRegistrationNonce();
        
        // Populate role from query parameter
        var role = getUrlParameter('td_user_role');
        console.log('👤 Role from URL:', role);
        if (role) {
            roleInput.value = role;
            console.log('✅ Role set to:', role);
            
            // Verify it was set
            setTimeout(function() {
                var checkRole = document.getElementById('td_user_role');
                console.log('🔍 Role value after verification:', checkRole ? checkRole.value : 'FIELD NOT FOUND');
            }, 500);
        } else {
            console.warn('⚠️ No role parameter in URL');
        }
        
        // Toggle LinkedIn URL field
        var hasLinkedIn = document.getElementById('has_linkedin');
        if (hasLinkedIn) {
            hasLinkedIn.addEventListener('change', function() {
                var linkedinSection = document.getElementById('linkedin_section');
                var linkedinUrl = document.getElementById('linkedin_url');
                
                if (this.checked) {
                    linkedinSection.style.display = 'block';
                    linkedinUrl.required = true;
                } else {
                    linkedinSection.style.display = 'none';
                    linkedinUrl.required = false;
                }
            });
        }
        
        // Toggle CV upload field
        var hasCv = document.getElementById('has_cv');
        if (hasCv) {
            hasCv.addEventListener('change', function() {
                var cvSection = document.getElementById('cv_section');
                var cvFile = document.getElementById('cv_file');
                
                if (this.checked) {
                    cvSection.style.display = 'block';
                    cvFile.required = true;
                } else {
                    cvSection.style.display = 'none';
                    cvFile.required = false;
                }
            });
        }
        
        // Toggle residence National ID field
        var liveInCitizenship = document.getElementById('live_in_citizenship_country');
        if (liveInCitizenship) {
            liveInCitizenship.addEventListener('change', function() {
                var residenceSection = document.getElementById('residence_id_section');
                var residenceFile = document.getElementById('national_id_residence');
                
                if (!this.checked) {
                    residenceSection.style.display = 'block';
                    residenceFile.required = true;
                } else {
                    residenceSection.style.display = 'none';
                    residenceFile.required = false;
                }
            });
        }
        
        // Real-time field validation
        var emailField = document.getElementById('email');
        if (emailField) {
            emailField.addEventListener('blur', function() {
                var emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                var errorSpan = this.nextElementSibling;
                
                if (this.value && !emailRegex.test(this.value)) {
                    this.style.borderColor = '#d32f2f';
                    if (!errorSpan || !errorSpan.classList.contains('field-error')) {
                        errorSpan = document.createElement('span');
                        errorSpan.className = 'field-error';
                        errorSpan.style.cssText = 'color: #d32f2f; font-size: 12px; display: block; margin-top: 4px;';
                        errorSpan.textContent = 'Please enter a valid email address';
                        this.parentNode.appendChild(errorSpan);
                    }
                } else {
                    this.style.borderColor = '';
                    if (errorSpan && errorSpan.classList.contains('field-error')) {
                        errorSpan.remove();
                    }
                }
            });
        }
        
        var phoneField = document.getElementById('phone');
        if (phoneField) {
            phoneField.addEventListener('blur', function() {
                var phoneRegex = /^[\d\s\+\-\(\)]+$/;
                var errorSpan = this.nextElementSibling;
                
                if (this.value && (!phoneRegex.test(this.value) || this.value.replace(/\D/g, '').length < 8)) {
                    this.style.borderColor = '#d32f2f';
                    if (!errorSpan || !errorSpan.classList.contains('field-error')) {
                        errorSpan = document.createElement('span');
                        errorSpan.className = 'field-error';
                        errorSpan.style.cssText = 'color: #d32f2f; font-size: 12px; display: block; margin-top: 4px;';
                        errorSpan.textContent = 'Please enter a valid phone number (min 8 digits)';
                        this.parentNode.appendChild(errorSpan);
                    }
                } else {
                    this.style.borderColor = '';
                    if (errorSpan && errorSpan.classList.contains('field-error')) {
                        errorSpan.remove();
                    }
                }
            });
        }
        
        var linkedinField = document.getElementById('linkedin_url');
        if (linkedinField) {
            linkedinField.addEventListener('blur', function() {
                var linkedinRegex = /linkedin\.com\/(in|pub|company)\//i;
                var errorSpan = this.nextElementSibling;
                
                if (this.value && !linkedinRegex.test(this.value)) {
                    this.style.borderColor = '#d32f2f';
                    if (!errorSpan || !errorSpan.classList.contains('field-error')) {
                        errorSpan = document.createElement('span');
                        errorSpan.className = 'field-error';
                        errorSpan.style.cssText = 'color: #d32f2f; font-size: 12px; display: block; margin-top: 4px;';
                        errorSpan.textContent = 'Please enter a valid LinkedIn profile URL';
                        this.parentNode.appendChild(errorSpan);
                    }
                } else {
                    this.style.borderColor = '';
                    if (errorSpan && errorSpan.classList.contains('field-error')) {
                        errorSpan.remove();
                    }
                }
            });
        }
        
        // Form validation and AJAX submission
        form.addEventListener('submit', function(e) {
            e.preventDefault();
            
            // Validate nonce is loaded
            var nonceField = document.getElementById('td_registration_nonce');
            if (!nonceField || !nonceField.value) {
                showFloatingMessage('Security token not loaded. Please wait a moment and try again.', 'error');
                return false;
            }
            
            // Email validation
            var emailField = document.getElementById('email');
            if (emailField && emailField.value) {
                var emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
                if (!emailRegex.test(emailField.value)) {
                    showFloatingMessage('Please enter a valid email address.', 'error');
                    emailField.focus();
                    return false;
                }
            }
            
            // Phone validation (basic international format)
            var phoneField = document.getElementById('phone');
            if (phoneField && phoneField.value) {
                var phoneRegex = /^[\d\s\+\-\(\)]+$/;
                if (!phoneRegex.test(phoneField.value) || phoneField.value.replace(/\D/g, '').length < 8) {
                    showFloatingMessage('Please enter a valid phone number (minimum 8 digits).', 'error');
                    phoneField.focus();
                    return false;
                }
            }
            
            var hasLinkedInChecked = document.getElementById('has_linkedin').checked;
            var hasCvChecked = document.getElementById('has_cv').checked;
            var linkedinUrl = document.getElementById('linkedin_url').value;
            var cvFile = document.getElementById('cv_file').files;
            
            // Check at least one checkbox is selected
            if (!hasLinkedInChecked && !hasCvChecked) {
                showFloatingMessage('Please select at least one option: LinkedIn profile or CV upload.', 'error');
                return false;
            }
            
            // Validate LinkedIn URL if checkbox is checked
            if (hasLinkedInChecked && !linkedinUrl) {
                showFloatingMessage('Please enter your LinkedIn profile URL.', 'error');
                document.getElementById('linkedin_url').focus();
                return false;
            }
            
            // Validate LinkedIn URL format
            if (hasLinkedInChecked && linkedinUrl) {
                var linkedinRegex = /linkedin\.com\/(in|pub|company)\//i;
                if (!linkedinRegex.test(linkedinUrl)) {
                    showFloatingMessage('Please enter a valid LinkedIn profile URL.', 'error');
                    document.getElementById('linkedin_url').focus();
                    return false;
                }
            }
            
            // Validate CV file if checkbox is checked
            if (hasCvChecked && (!cvFile || cvFile.length === 0)) {
                showFloatingMessage('Please upload your CV file.', 'error');
                return false;
            }
            
            // Validate CV file size and type
            if (hasCvChecked && cvFile.length > 0) {
                var file = cvFile[0];
                var maxSize = 5 * 1024 * 1024; // 5MB
                var allowedTypes = ['application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'];
                
                if (file.size > maxSize) {
                    showFloatingMessage('CV file size must not exceed 5MB.', 'error');
                    return false;
                }
                
                if (allowedTypes.indexOf(file.type) === -1) {
                    showFloatingMessage('CV file must be PDF, DOC, or DOCX format.', 'error');
                    return false;
                }
            }
            
            // Validate citizenship ID file
            var citizenshipFile = document.getElementById('national_id_citizenship').files;
            if (citizenshipFile.length > 0) {
                var file = citizenshipFile[0];
                var maxSize = 5 * 1024 * 1024; // 5MB
                var allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'application/pdf'];
                
                if (file.size > maxSize) {
                    showFloatingMessage('National ID file size must not exceed 5MB.', 'error');
                    return false;
                }
                
                if (allowedTypes.indexOf(file.type) === -1) {
                    showFloatingMessage('National ID must be JPG, PNG, or PDF format.', 'error');
                    return false;
                }
            }
            
            // Validate residence ID file if applicable
            var residenceFile = document.getElementById('national_id_residence').files;
            if (residenceFile.length > 0) {
                var file = residenceFile[0];
                var maxSize = 5 * 1024 * 1024; // 5MB
                var allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'application/pdf'];
                
                if (file.size > maxSize) {
                    showFloatingMessage('Residence ID file size must not exceed 5MB.', 'error');
                    return false;
                }
                
                if (allowedTypes.indexOf(file.type) === -1) {
                    showFloatingMessage('Residence ID must be JPG, PNG, or PDF format.', 'error');
                    return false;
                }
            }
            
            var consent = document.querySelector('input[name="consent"]:checked');
            if (!consent) {
                showFloatingMessage('Please accept the Privacy Policy and Terms & Conditions.', 'error');
                return false;
            }
            
            // Disable submit button to prevent double submission
            var submitBtn = this.querySelector('.submit-btn');
            submitBtn.disabled = true;
            submitBtn.textContent = 'Submitting...';
            
            // Submit form via AJAX
            var formData = new FormData(this);
            
            // DEBUG: Log all form data being sent
            console.log('📤 Form data being submitted:');
            for (var pair of formData.entries()) {
                console.log('  ' + pair[0] + ':', pair[1]);
            }
            
            fetch('/wp-admin/admin-ajax.php', {
                method: 'POST',
                body: formData
            })
            .then(function(response) { return response.json(); })
            .then(function(data) {
                if (data.success) {
                    showFloatingMessage('Registration successful! Redirecting...', 'success');
                } else {
                    showFloatingMessage(data.data.message || data.data || 'Registration failed. Please try again.', 'error');
                    submitBtn.disabled = false;
                    submitBtn.textContent = 'Submit Registration';
                }
            })
            .catch(function(error) {
                showFloatingMessage('An error occurred. Please try again.', 'error');
                submitBtn.disabled = false;
                submitBtn.textContent = 'Submit Registration';
            });
        });
        
        // File upload display names with validation
        var cvFileInput = document.getElementById('cv_file');
        if (cvFileInput) {
            cvFileInput.addEventListener('change', function(e) {
                var file = e.target.files[0];
                var nameDisplay = document.getElementById('cv_file_name');
                var errorSpan = this.nextElementSibling;
                
                if (!file) {
                    nameDisplay.textContent = '';
                    return;
                }
                
                var maxSize = 5 * 1024 * 1024; // 5MB
                var allowedTypes = ['application/pdf', 'application/msword', 'application/vnd.openxmlformats-officedocument.wordprocessingml.document'];
                var isValid = true;
                var errorMsg = '';
                
                if (file.size > maxSize) {
                    isValid = false;
                    errorMsg = 'File too large (max 5MB)';
                } else if (allowedTypes.indexOf(file.type) === -1) {
                    isValid = false;
                    errorMsg = 'Invalid file type (PDF, DOC, DOCX only)';
                }
                
                if (isValid) {
                    var sizeKB = (file.size / 1024).toFixed(1);
                    nameDisplay.textContent = 'Selected: ' + file.name + ' (' + sizeKB + ' KB)';
                    nameDisplay.style.color = '#2e7d32';
                    this.style.borderColor = '';
                    if (errorSpan && errorSpan.classList.contains('field-error')) {
                        errorSpan.remove();
                    }
                } else {
                    nameDisplay.textContent = 'Error: ' + errorMsg;
                    nameDisplay.style.color = '#d32f2f';
                    this.style.borderColor = '#d32f2f';
                    this.value = ''; // Clear invalid file
                }
            });
        }
        
        var citizenshipFileInput = document.getElementById('national_id_citizenship');
        if (citizenshipFileInput) {
            citizenshipFileInput.addEventListener('change', function(e) {
                var file = e.target.files[0];
                var nameDisplay = document.getElementById('national_id_citizenship_name');
                
                if (!file) {
                    nameDisplay.textContent = '';
                    return;
                }
                
                var maxSize = 5 * 1024 * 1024; // 5MB
                var allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'application/pdf'];
                var isValid = true;
                var errorMsg = '';
                
                if (file.size > maxSize) {
                    isValid = false;
                    errorMsg = 'File too large (max 5MB)';
                } else if (allowedTypes.indexOf(file.type) === -1) {
                    isValid = false;
                    errorMsg = 'Invalid file type (JPG, PNG, PDF only)';
                }
                
                if (isValid) {
                    var sizeKB = (file.size / 1024).toFixed(1);
                    nameDisplay.textContent = 'Selected: ' + file.name + ' (' + sizeKB + ' KB)';
                    nameDisplay.style.color = '#2e7d32';
                    this.style.borderColor = '';
                } else {
                    nameDisplay.textContent = 'Error: ' + errorMsg;
                    nameDisplay.style.color = '#d32f2f';
                    this.style.borderColor = '#d32f2f';
                    this.value = ''; // Clear invalid file
                }
            });
        }
        
        var residenceFileInput = document.getElementById('national_id_residence');
        if (residenceFileInput) {
            residenceFileInput.addEventListener('change', function(e) {
                var file = e.target.files[0];
                var nameDisplay = document.getElementById('national_id_residence_name');
                
                if (!file) {
                    nameDisplay.textContent = '';
                    return;
                }
                
                var maxSize = 5 * 1024 * 1024; // 5MB
                var allowedTypes = ['image/jpeg', 'image/jpg', 'image/png', 'application/pdf'];
                var isValid = true;
                var errorMsg = '';
                
                if (file.size > maxSize) {
                    isValid = false;
                    errorMsg = 'File too large (max 5MB)';
                } else if (allowedTypes.indexOf(file.type) === -1) {
                    isValid = false;
                    errorMsg = 'Invalid file type (JPG, PNG, PDF only)';
                }
                
                if (isValid) {
                    var sizeKB = (file.size / 1024).toFixed(1);
                    nameDisplay.textContent = 'Selected: ' + file.name + ' (' + sizeKB + ' KB)';
                    nameDisplay.style.color = '#2e7d32';
                    this.style.borderColor = '';
                } else {
                    nameDisplay.textContent = 'Error: ' + errorMsg;
                    nameDisplay.style.color = '#d32f2f';
                    this.style.borderColor = '#d32f2f';
                    this.value = ''; // Clear invalid file
                }
            });
        }
    }
})();
