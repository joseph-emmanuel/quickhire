# Use official PHP image
FROM php:8.2-cli

# Install system dependencies including Node.js from NodeSource
RUN apt-get update && apt-get install -y \
    git curl unzip sqlite3 libsqlite3-dev \
    libpng-dev libonig-dev libxml2-dev zip gnupg ca-certificates

# Install Node.js LTS (to avoid rollup native module errors)
RUN curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

# Install required PHP extensions
RUN docker-php-ext-install pdo pdo_sqlite mbstring exif pcntl bcmath gd

# Set working directory
WORKDIR /var/www

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy project files into the container
COPY . .

# Create .env file from example
COPY .env.example .env

# Install PHP dependencies
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Clean up potential broken cache from host
RUN rm -rf node_modules package-lock.json && npm cache clean --force

# Install Node.js dependencies and build front-end assets
RUN npm install && npm run build

# Generate Laravel app key
RUN php artisan key:generate

# Expose port 8000 for Laravel's built-in server
EXPOSE 8000

# Start Laravel development server
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
