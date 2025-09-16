# PHP 8.3 + Composer + Nginx Unit tabanlı Laravel runtime
FROM serversideup/php:8.3-unit

# ---> BURADAN EKLE / GÜNCELLE <---
USER root
RUN set -eux; \
    mkdir -p /var/lib/apt/lists/partial; \
    apt-get update; \
    apt-get install -y --no-install-recommends git unzip libpq-dev; \
    docker-php-ext-install pdo_pgsql; \
    rm -rf /var/lib/apt/lists/*
# <--- EKLEME BİTTİ ---

WORKDIR /var/www/html

# Composer bağımlılıkları
COPY composer.json composer.lock* ./
RUN composer install --no-dev --prefer-dist --no-interaction --no-ansi --no-progress

# Uygulama dosyaları
COPY . .

# Laravel için izinler
RUN chown -R www-data:www-data storage bootstrap/cache \
 && chmod -R ug+rwX storage bootstrap/cache

# Env fallback
RUN cp -n .env.example .env || true

# Nginx Unit konfigürasyonu
COPY unit.json /docker-entrypoint.d/unit.json

# Önbellek (ilk deployda key yoksa sorun değil)
RUN php artisan config:clear || true

EXPOSE 8000
CMD ["unitd", "--no-daemon"]