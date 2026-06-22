FROM php:8.4-apache

# Enable Apache modules
RUN a2enmod rewrite headers expires

# Install required packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    libicu-dev \
    libjpeg-dev \
    libpng-dev \
    libfreetype6-dev \
 && rm -rf /var/lib/apt/lists/*

# Configure and install PHP extensions
RUN docker-php-ext-configure intl \
 && docker-php-ext-install -j"$(nproc)" intl pdo_mysql mysqli opcache \
 && docker-php-ext-enable mysqli

# Configure and install GD with JPEG and PNG support
RUN docker-php-ext-configure gd --with-jpeg --with-freetype \
 && docker-php-ext-install -j"$(nproc)" gd

# Set Apache document root
ARG APACHE_DOCUMENT_ROOT=/var/www/html/public
ENV APACHE_DOCUMENT_ROOT=${APACHE_DOCUMENT_ROOT}
RUN sed -ri "s!/var/www/html!${APACHE_DOCUMENT_ROOT}!g" /etc/apache2/sites-available/*.conf /etc/apache2/apache2.conf \
 && sed -ri 's/AllowOverride None/AllowOverride All/i' /etc/apache2/apache2.conf
