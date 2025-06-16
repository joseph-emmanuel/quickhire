# Use official PHP image
FROM php:8.2-cli

# Install system dependencies + Node.js
RUN apt-get update && apt-get install -y \
    git curl unzip sqlite3 libsqlite3-dev \
    libpng-dev libonig-dev libxml2-dev zip gnupg ca-certificates \
    && curl -fsSL https://deb.nodesource.com/setup_18.x | bash - \
    && apt-get install -y nodejs

# Install PHP extensions
RUN docker-php-ext-install pdo pdo_sqlite mbstring exif pcntl bcmath gd

# Set working directory
WORKDIR /var/www

# Install Composer
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer

# Copy project files
COPY . .

# Create .env file from example
COPY .env.example .env

# Install backend dependencies
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Clean npm cache and install frontend dependencies
RUN rm -rf node_modules package-lock.json && npm cache clean --force
RUN npm install && npm run build

# Generate Laravel app key
RUN php artisan key:generate

# Copy built assets to public (make sure manifest.json is in /public/build)
RUN cp -r public/build /var/www/public/build

# Expose port
EXPOSE 8000

# Start Laravel server
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
