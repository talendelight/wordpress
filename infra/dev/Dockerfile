# Custom WordPress image with WP-CLI
FROM wordpress:6.9.0-php8.3-apache

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp \
    && wp --info --allow-root

# Verify installation
RUN wp --version --allow-root

# Continue with default WordPress entrypoint
