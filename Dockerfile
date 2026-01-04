FROM php:8.2-apache

# نصب پیش‌نیازهای سیستم
RUN apt-get update && apt-get install -y \
    libpng-dev \
    libonig-dev \
    libxml2-dev \
    zip \
    unzip \
    git \
    curl

# نصب افزونه‌های PHP مورد نیاز لاراول
RUN docker-php-ext-install pdo_mysql mbstring exif pcntl bcmath gd

# فعال‌سازی مد بازنویسی آپاچی برای لاراول
RUN a2enmod rewrite

# کپی کردن کدهای پروژه به داخل سرور
COPY . /var/www/html

# تنظیم دسترسی‌ها
RUN chown -R www-data:www-data /var/www/html/storage /var/www/html/bootstrap/cache

# تنظیم مسیر اصلی به پوشه public لاراول
ENV APACHE_DOCUMENT_ROOT /var/www/html/public
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/sites-available/*.conf
RUN sed -ri -e 's!/var/www/html!${APACHE_DOCUMENT_ROOT}!g' /etc/apache2/apache2.conf /etc/apache2/conf-available/*.conf

# نصب کامپوزر
COPY --from=composer:latest /usr/bin/composer /usr/bin/composer
RUN composer install --no-dev --optimize-autoloader

EXPOSE 80
