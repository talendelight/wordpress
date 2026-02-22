/**
 * Manager Actions Page - Tab Switching Logic
 * Handles 5-tab interface: New, Assigned, Approved, Rejected, All
 * Version: 1.0.0
 */

(function() {
    'use strict';
    
    // Wait for DOM to be ready
    if (document.readyState === 'loading') {
        document.addEventListener('DOMContentLoaded', init);
    } else {
        init();
    }
    
    function init() {
        const tabButtons = document.querySelectorAll('.td-tab-button');
        const tabContents = document.querySelectorAll('.td-tab-content');
        
        if (tabButtons.length === 0 || tabContents.length === 0) {
            console.warn('Manager Actions: Tab elements not found');
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
                
                // Show target content
                const targetContent = document.getElementById('tab-' + targetTab);
                if (targetContent) {
                    targetContent.classList.add('active');
                    targetContent.style.display = 'block';
                } else {
                    console.error('Manager Actions: Tab content not found for:', targetTab);
                }
            });
        });
        
        // Hover effects
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
        
        console.log('Manager Actions tabs initialized (' + tabButtons.length + ' tabs)');
    }
})();
