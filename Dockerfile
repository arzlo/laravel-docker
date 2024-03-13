# Use the official PHP image as base image
FROM php:8.2.12-apache

# Install system dependencies
RUN apt-get update \
    && apt-get install -y \
        libzip-dev \
        unzip \
        git \
        libonig-dev \
        libxml2-dev \
    && docker-php-ext-install pdo_mysql zip mbstring exif pcntl bcmath \
    && a2enmod rewrite

# Set the working directory
WORKDIR /var/www/html

# Copy composer.lock and composer.json
COPY composer.lock composer.json /var/www/html/

# Install composer dependencies
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
    && composer install --no-scripts --no-autoloader

# Copy existing application directory contents
COPY . /var/www/html

# Generate the autoload files and cache
RUN composer dump-autoload --optimize \
    && php artisan config:cache \
    && php artisan route:cache \
    && php artisan view:cache

# Set permissions
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# Expose port 80 and start Apache
EXPOSE 80
CMD ["apache2-foreground"]
