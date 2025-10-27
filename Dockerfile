# Gunakan base image PHP dengan Apache bawaan
FROM php:8.1-apache

# Set direktori kerja
WORKDIR /var/www/html

# Install dependencies system dan PHP extensions yang dibutuhkan WinterCMS
RUN apt-get clean && apt-get update -o Acquire::Retries=5 --fix-missing && apt-get install -y \
    zip unzip git curl libzip-dev libpng-dev libjpeg62-turbo-dev libfreetype6-dev libxml2-dev \
 && docker-php-ext-configure gd --with-freetype --with-jpeg \
 && docker-php-ext-install -j$(nproc) pdo_mysql mbstring exif pcntl bcmath gd tokenizer xml \
 && a2enmod rewrite \
 && rm -rf /var/lib/apt/lists/*

# Salin file composer.json terlebih dahulu agar cache build efisien
COPY composer.json composer.lock ./

# Install Composer dan dependency project
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer \
 && php -d memory_limit=-1 /usr/local/bin/composer install --no-dev --optimize-autoloader --prefer-dist --no-interaction

# Salin semua file project setelah dependensi selesai
COPY . .

# Set permission agar folder penting bisa ditulis
RUN chown -R www-data:www-data storage bootstrap/cache

# Aktifkan mod_rewrite agar route WinterCMS bisa jalan
RUN echo "<Directory /var/www/html>\n\
    AllowOverride All\n\
    Require all granted\n\
</Directory>" > /etc/apache2/conf-enabled/wintercms.conf

# Buka port HTTP standar
EXPOSE 80

# Healthcheck agar DeployAja tidak gagal health probe
HEALTHCHECK CMD curl -f http://localhost/ || exit 1

# Jalankan Apache di foreground
CMD ["apache2-foreground"]
