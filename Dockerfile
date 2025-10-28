# Rebuild trigger 2025-10-27
FROM php:8.2-apache

# Set ServerName agar tidak muncul warning
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Set direktori kerja
WORKDIR /var/www/html

# Install dependency sistem
RUN apt-get update && apt-get install -y \
    zip unzip git curl ca-certificates \
    libzip-dev libpng-dev libjpeg62-turbo-dev libfreetype6-dev libxml2-dev libonig-dev \
    libicu-dev \
    && rm -rf /var/lib/apt/lists/*

# Configure dan install ekstensi PHP
RUN docker-php-ext-configure gd --with-freetype --with-jpeg
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd xml intl fileinfo zip
RUN a2enmod rewrite

# Install Composer (pastikan sebelum digunakan)
RUN curl -sSL https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
  && chmod +x /usr/local/bin/composer

# Salin composer.json & composer.lock untuk caching layer
COPY composer.json composer.lock ./

# Set permission agar Composer tidak error "permission denied"
RUN chown -R www-data:www-data /var/www/html

# Install dependensi PHP via Composer
RUN COMPOSER_MEMORY_LIMIT=-1 composer install --no-dev --optimize-autoloader --prefer-dist --no-interaction

# Salin seluruh project
COPY . .

# Set permission folder penting
RUN chown -R www-data:www-data storage bootstrap/cache

# Konfigurasi Apache untuk WinterCMS
RUN echo "<Directory /var/www/html>\n\
    AllowOverride All\n\
    Require all granted\n\
</Directory>" > /etc/apache2/conf-enabled/wintercms.conf \
 && echo 'DirectoryIndex index.php index.html' >> /etc/apache2/apache2.conf

# Expose port 80
EXPOSE 80

# Healthcheck
HEALTHCHECK CMD curl -f http://localhost/ || exit 1

# Jalankan Apache
CMD ["apache2-foreground"]
