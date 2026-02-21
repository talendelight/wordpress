# Custom WordPress image with WP-CLI
FROM wordpress:6.9.1-php8.3-apache

# Install OS packages needed to compile PHP extensions
RUN apt-get update && apt-get install -y --no-install-recommends \
      libcurl4-openssl-dev \
      pkg-config \
      libxml2-dev \
    && rm -rf /var/lib/apt/lists/*

# Install PHP extensions
# - json is built into PHP 8.x (do NOT docker-php-ext-install json)
# - dom typically works once libxml2-dev exists (often already enabled, but safe)
RUN docker-php-ext-install curl dom

# Note: libxml is included by default in PHP docker images
# curl, dom, json, libxml extensions are now available

# Install WP-CLI
RUN curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar \
    && chmod +x wp-cli.phar \
    && mv wp-cli.phar /usr/local/bin/wp \
    && wp --info --allow-root

# Verify installation
RUN wp --version --allow-root

# Continue with default WordPress entrypoint
