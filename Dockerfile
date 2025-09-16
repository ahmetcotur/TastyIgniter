FROM serversideup/php:8.3-unit

# root'a geç ve gerekli paket/eklentileri kur
USER root
RUN set -eux; \
    mkdir -p /var/lib/apt/lists/partial; \
    apt-get update; \
    apt-get install -y --no-install-recommends \
        git unzip libpq-dev libicu-dev ; \
    docker-php-ext-install pdo_pgsql intl ; \
    rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

# --- ÖNCE composer manifest & LOCK'u kopyala (lock dosyasını ZORUNLU kopyala) ---
COPY composer.json ./
RUN composer install --no-dev --prefer-dist --no-interaction --no-ansi --no-progress

# Uygulama dosyaları
COPY . .

# Laravel izinleri
RUN chown -R www-data:www-data storage bootstrap/cache \
 && chmod -R ug+rwX storage bootstrap/cache

# Env fallback
RUN cp -n .env.example .env || true

# Nginx Unit config
COPY unit.json /docker-entrypoint.d/unit.json

RUN php artisan config:clear || true

EXPOSE 8000
CMD ["unitd", "--no-daemon"]