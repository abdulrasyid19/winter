FROM php:8.2-apache

WORKDIR /var/www/html

# Install system dependencies & PHP extensions
RUN apt-get update && apt-get install -y \
    zip unzip git curl libzip-dev libpng-dev libonig-dev libxml2-dev \
    && docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd tokenizer xml \
    && a2enmod rewrite

# Copy project files
COPY . .

# Set permissions awal
RUN chown -R www-data:www-data storage bootstrap/cache

# Install Composer
RUN curl -sS https://getcomposer.org/installer | php -- --install-dir=/usr/local/bin --filename=composer

# Install dependencies composer
RUN php -d memory_limit=-1 /usr/local/bin/composer install --no-dev --optimize-autoloader --prefer-dist --no-interaction

EXPOSE 80

CMD ["apache2-foreground"]
