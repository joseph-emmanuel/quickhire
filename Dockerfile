# Use official PHP image with CLI tools
FROM php:8.2-cli

# Install system dependencies
RUN apt-get update && apt-get install -y \
    git curl unzip sqlite3 libsqlite3-dev \
    libpng-dev libonig-dev libxml2-dev zip

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

# Install Laravel dependencies
RUN composer install --no-interaction --prefer-dist --optimize-autoloader

# Generate Laravel app key
RUN php artisan key:generate

# Expose port 8000 for the web server
EXPOSE 8000

# Start Laravel's built-in server
CMD ["php", "artisan", "serve", "--host=0.0.0.0", "--port=8000"]
