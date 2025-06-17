# Use official PHP image
FROM php:8.2-cli

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git curl unzip sqlite3 libsqlite3-dev \
    libpng-dev libonig-dev libxml2-dev zip \
    nodejs npm

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_sqlite mbstring exif pcntl bcmath gd

# Set working directory
WORKDIR /var/www

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy project files
COPY . .

# Set correct .env with ASSET_URL
COPY .env.example .env

# Install PHP dependencies
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Clean and build frontend assets
RUN rm -rf node_modules package-lock.json && npm cache clean --force
RUN npm install && npm run build

# Generate app key
RUN php artisan key:generate

# Expose Laravel's default port
EXPOSE 8000

# Start Laravel server
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
