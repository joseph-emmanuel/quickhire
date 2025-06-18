
FROM php:8.2-fpm

RUN apt-get update && apt-get install -y \
    nginx supervisor git unzip curl zip sqlite3 libsqlite3-dev libpng-dev libonig-dev libxml2-dev \
    libzip-dev libcurl4-openssl-dev pkg-config libssl-dev nodejs npm

RUN docker-php-ext-install pdo pdo_sqlite mbstring exif pcntl bcmath gd

COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

WORKDIR /var/www

COPY . .

COPY .render/nginx.conf /etc/nginx/sites-available/default
COPY .render/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN composer install --no-interaction --prefer-dist --optimize-autoloader
RUN npm install && npm run build
RUN php artisan key:generate

EXPOSE 8080

CMD ["/usr/bin/supervisord"]
