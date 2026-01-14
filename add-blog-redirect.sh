#!/bin/bash
# Скрипт для добавления 301 редиректа с blog.speakid.ru на speakid.ru/blog/
# ВАЖНО: Перед выполнением убедись, что DNS для blog.speakid.ru указывает на IP сервера с Nginx

NGINX_CONF="/etc/nginx/nginx.conf"
BACKUP_FILE="/etc/nginx/nginx.conf.backup.$(date +%Y%m%d_%H%M%S)"

# Создаём backup
echo "Создаю backup: $BACKUP_FILE"
sudo cp "$NGINX_CONF" "$BACKUP_FILE"

# Находим строку с server_name speakid.ru и получаем SSL сертификаты
SSL_CERT=$(sudo grep -A 20 "server_name speakid.ru" "$NGINX_CONF" | grep "ssl_certificate " | head -1 | awk '{print $2}' | tr -d ';')
SSL_KEY=$(sudo grep -A 20 "server_name speakid.ru" "$NGINX_CONF" | grep "ssl_certificate_key" | head -1 | awk '{print $2}' | tr -d ';')

if [ -z "$SSL_CERT" ] || [ -z "$SSL_KEY" ]; then
    echo "ОШИБКА: Не удалось найти SSL сертификаты для speakid.ru"
    echo "Проверь конфигурацию вручную"
    exit 1
fi

echo "Найдены SSL сертификаты:"
echo "  Certificate: $SSL_CERT"
echo "  Key: $SSL_KEY"

# Создаём временный файл с новым server блоком
TEMP_BLOCK=$(mktemp)
cat > "$TEMP_BLOCK" << EOF
	# Редирект с blog.speakid.ru на speakid.ru/blog/
	server {
		listen 443 ssl http2;
		server_name blog.speakid.ru;
		
		ssl_certificate $SSL_CERT;
		ssl_certificate_key $SSL_KEY;
		
		# Редирект всех запросов на speakid.ru/blog/ с сохранением пути
		location / {
			return 301 https://speakid.ru/blog\$request_uri;
		}
	}
	
	# HTTP редирект на HTTPS
	server {
		listen 80;
		server_name blog.speakid.ru;
		return 301 https://speakid.ru/blog\$request_uri;
	}
	
EOF

# Находим строку с "server_name speakid.ru" и вставляем блок перед ней
# Используем awk для безопасной вставки
sudo awk -v block="$(cat "$TEMP_BLOCK")" '
	/server_name speakid.ru/ && !inserted {
		print block
		inserted = 1
	}
	{ print }
' "$NGINX_CONF" > "$NGINX_CONF.new"

# Проверяем синтаксис
if sudo nginx -t; then
    echo "✓ Синтаксис Nginx корректен"
    sudo mv "$NGINX_CONF.new" "$NGINX_CONF"
    echo "✓ Конфигурация обновлена"
    echo ""
    echo "Для применения изменений выполни:"
    echo "  sudo systemctl reload nginx"
else
    echo "✗ ОШИБКА: Синтаксис Nginx некорректен"
    echo "Откатываю изменения..."
    sudo mv "$BACKUP_FILE" "$NGINX_CONF"
    rm -f "$NGINX_CONF.new"
    exit 1
fi

rm -f "$TEMP_BLOCK"
echo "Готово! Backup сохранён: $BACKUP_FILE"
