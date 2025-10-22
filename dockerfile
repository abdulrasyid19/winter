# Gunakan image PHP dengan Apache
FROM php:8.2-apache

# Install ekstensi PHP yang dibutuhkan Winter CMS
RUN apt-get update && apt-get install -y \
    zip unzip git curl libpng-dev libjpeg-dev libfreetype6-dev libonig-dev libxml2-dev && \
    docker-php-ext-configure gd --with-freetype --with-jpeg && \
    docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# Set working directory
WORKDIR /var/www/html

# Copy semua file project ke container
COPY . .

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install dependencies PHP
RUN composer install --no-dev --optimize-autoloader

# Aktifkan mod_rewrite untuk Apache
RUN a2enmod rewrite

# Set permission folder penting
RUN chmod -R 775 storage bootstrap/cache

# Expose port 80
EXPOSE 80

# Jalankan Apache
CMD ["apache2-foreground"]
