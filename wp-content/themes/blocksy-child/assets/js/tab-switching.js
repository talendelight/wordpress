/**
 * Tab Switching Functionality for Manager Actions and Operator Actions Pages
 * 
 * Handles tab switching with click events and hover effects for approval tables.
 * Used on: Manager Actions (/managers/actions/), Operator Actions (/operators/actions/)
 * 
 * @version 1.0.0
 * @since v3.7.3
 */

(function() {
    'use strict';

    // Wait for DOM to be fully loaded
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', initTabSwitching);
    } else {
        initTabSwitching();
    }

    function initTabSwitching() {
        const tabButtons = document.querySelectorAll('.td-tab-button');
        const tabContents = document.querySelectorAll('.td-tab-content');

        // Exit if no tabs found on page
        if (tabButtons.length === 0 || tabContents.length === 0) {
            return;
        }

        // Tab click handlers
        tabButtons.forEach(button => {
            button.addEventListener('click', function() {
                const targetTab = this.getAttribute('data-tab');

                // Remove active class from all buttons and contents
                tabButtons.forEach(btn => {
                    btn.classList.remove('active');
                    btn.style.borderBottomColor = 'transparent';
                    btn.style.color = '#666';
                    btn.style.background = '#f8f8f8';
                });
                tabContents.forEach(content => {
                    content.classList.remove('active');
                    content.style.display = 'none';
                });

                // Add active class to clicked button and corresponding content
                this.classList.add('active');
                this.style.borderBottomColor = '#3498DB';
                this.style.color = '#063970';
                this.style.background = this.getAttribute('data-color');
                
                const targetContent = document.getElementById('tab-' + targetTab);
                if (targetContent) {
                    targetContent.classList.add('active');
                    targetContent.style.display = 'block';
                }
            });
        });

        // Hover effects for inactive tabs
        tabButtons.forEach(button => {
            button.addEventListener('mouseenter', function() {
                if (!this.classList.contains('active')) {
                    this.style.borderBottomColor = '#3498DB';
                    this.style.background = this.getAttribute('data-color');
                }
            });
            
            button.addEventListener('mouseleave', function() {
                if (!this.classList.contains('active')) {
                    this.style.borderBottomColor = 'transparent';
                    this.style.background = '#f8f8f8';
                }
            });
        });

        // Debugging: Log successful initialization (remove in production)
        if (window.console && console.log) {
            console.log('Tab switching initialized:', tabButtons.length, 'tabs found');
        }
    }
})();
