# PHP 8.3 + Composer + Nginx Unit tabanlı Laravel runtime
FROM serversideup/php:8.3-unit

# Sistem paketleri (isteğe bağlı: git, unzip)
RUN apt-get update && apt-get install -y git unzip && rm -rf /var/lib/apt/lists/*

WORKDIR /var/www/html

# Composer bağımlılıkları
COPY composer.json composer.lock* ./
RUN composer install --no-dev --prefer-dist --no-interaction --no-ansi --no-progress

# Uygulama dosyaları
COPY . .

# Laravel için izinler
RUN chown -R www-data:www-data storage bootstrap/cache \
 && chmod -R ug+rwX storage bootstrap/cache

# Env örneğini kopyalamak (Coolify env geçiriyor, ama fallback dursun)
RUN cp -n .env.example .env || true

# Nginx Unit konfigürasyonu
COPY unit.json /docker-entrypoint.d/unit.json

# Önbellekler (ilk deployda app key yoksa hata verirse sorun değil)
RUN php artisan config:clear || true

EXPOSE 8000
CMD ["unitd", "--no-daemon"]