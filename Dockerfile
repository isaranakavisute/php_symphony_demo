# Use an official PHP-FPM image as the base
FROM php:8.2-fpm-alpine

# Install system dependencies and PHP extensions required by Symfony
RUN apk add --no-cache \
    git \
    zip \
    unzip \
    icu-dev \
    libxml2-dev \
    oniguruma-dev \
    postgresql-dev \
    nginx \
    build-base \
    autoconf \
    g++ \
    make \
    pcre-dev \
    zlib-dev \
    libpng-dev \
    libjpeg-turbo-dev \
    freetype-dev \
    libwebp-dev \
    libxpm-dev \
    && docker-php-ext-install -j$(nproc) \
        pdo_mysql \
        pdo_pgsql \
        intl \
        zip \
        gd \
        exif \
        mbstring \
    && docker-php-ext-enable \
        opcache

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Set the working directory inside the container
WORKDIR /var/www/html

# Copy the Symfony application files into the container
COPY . .

# Install Symfony dependencies using Composer
RUN composer install --no-dev --optimize-autoloader --no-interaction

# Configure permissions for Symfony cache and logs
RUN chown -R www-data:www-data var public \
    && chmod -R 775 var public

# Expose port 9000 for PHP-FPM
EXPOSE 9000

# Start PHP-FPM
CMD ["php-fpm"]
