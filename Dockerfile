# Rebuild trigger 2025-10-27
FROM php:8.1-apache

# Set ServerName agar tidak muncul warning
RUN echo "ServerName localhost" >> /etc/apache2/apache2.conf

# Set direktori kerja
WORKDIR /var/www/html

# Install dependency sistem dan ekstensi PHP
RUN apt-get update && apt-get install -y \
    zip unzip git curl libzip-dev libpng-dev libjpeg-dev libfreetype6-dev libxml2-dev libonig-dev \
    && docker-php-ext-configure gd --with-freetype --with-jpeg \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd tokenizer xml \
    && a2enmod rewrite \
    && rm -rf /var/lib/apt/lists/*

# Salin composer.json terlebih dahulu agar cache efisien
COPY composer.json composer.lock ./

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install dependensi PHP dari composer
RUN composer install --no-dev --optimize-autoloader --prefer-dist --no-interaction || true

# Salin seluruh file project ke container
COPY . .

# Set permission folder penting
RUN chown -R www-data:www-data storage bootstrap/cache

# Pastikan Apache tahu file index-nya
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
