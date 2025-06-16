# Use official PHP image with CLI tools
FROM php:8.2-cli

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git curl unzip sqlite3 libsqlite3-dev \
    libpng-dev libonig-dev libxml2-dev zip nodejs npm

# Install required PHP extensions
RUN docker-php-ext-install pdo pdo_sqlite mbstring exif pcntl bcmath gd

# Set working directory
WORKDIR /var/www

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy project files into the container
COPY . .

# Copy .env.example to .env (or handle via Render secrets if preferred)
COPY .env.example .env

# Install PHP dependencies
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Install Node.js dependencies and build front-end assets
RUN npm install && npm run build

# Generate Laravel app key
RUN php artisan key:generate

# Expose port 8000 for Laravel's built-in server
EXPOSE 8000

# Start Laravel development server
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
