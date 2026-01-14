#!/bin/bash
# Исправленная команда для добавления 301 редиректа
# Вставляет server блок ПЕРЕД блоком server для speakid.ru

NGINX_CONF="/etc/nginx/nginx.conf"
BACKUP="/etc/nginx/nginx.conf.backup.$(date +%Y%m%d_%H%M%S)"

echo "Создаю backup: $BACKUP"
sudo cp "$NGINX_CONF" "$BACKUP"

# Получаем SSL сертификаты
SSL_CERT=$(sudo grep -A 20 "server_name speakid.ru" "$NGINX_CONF" | grep "ssl_certificate " | head -1 | awk '{print $2}' | tr -d ';')
SSL_KEY=$(sudo grep -A 20 "server_name speakid.ru" "$NGINX_CONF" | grep "ssl_certificate_key" | head -1 | awk '{print $2}' | tr -d ';')

if [ -z "$SSL_CERT" ] || [ -z "$SSL_KEY" ]; then
    echo "✗ ОШИБКА: Не найдены SSL сертификаты"
    exit 1
fi

echo "✓ Найдены SSL сертификаты: $SSL_CERT"

# Находим номер строки с началом server блока для speakid.ru
# Ищем строку "server {" которая находится перед "server_name speakid.ru"
SERVER_LINE=$(sudo awk '/^[[:space:]]*server[[:space:]]*\{/ {line=NR; block_start=1} block_start && /server_name speakid.ru/ {print line; exit}' "$NGINX_CONF")

if [ -z "$SERVER_LINE" ]; then
    echo "✗ ОШИБКА: Не найден server блок для speakid.ru"
    exit 1
fi

echo "✓ Найден server блок на строке $SERVER_LINE"

# Создаём блок редиректа
REDIRECT_BLOCK=$(cat <<EOF
	# Редирект с blog.speakid.ru на speakid.ru/blog/
	server {
		listen 443 ssl http2;
		server_name blog.speakid.ru;
		
		ssl_certificate $SSL_CERT;
		ssl_certificate_key $SSL_KEY;
		
		return 301 https://speakid.ru/blog\$request_uri;
	}
	
	server {
		listen 80;
		server_name blog.speakid.ru;
		return 301 https://speakid.ru/blog\$request_uri;
	}
	
EOF
)

# Вставляем блок перед строкой $SERVER_LINE
sudo awk -v insert_line="$SERVER_LINE" -v block="$REDIRECT_BLOCK" '
	NR == insert_line {
		print block
	}
	{ print }
' "$NGINX_CONF" > /tmp/nginx.conf.new

# Проверяем синтаксис
if sudo nginx -t 2>/dev/null; then
    echo "✓ Синтаксис корректен"
    sudo mv /tmp/nginx.conf.new "$NGINX_CONF"
    echo "✓ Конфигурация обновлена"
    echo ""
    echo "Применяю изменения..."
    if sudo systemctl reload nginx; then
        echo "✓ Готово! Редирект настроен"
        echo "Backup: $BACKUP"
    else
        echo "✗ ОШИБКА при перезагрузке Nginx"
        echo "Откатываю изменения..."
        sudo mv "$BACKUP" "$NGINX_CONF"
        exit 1
    fi
else
    echo "✗ ОШИБКА: Синтаксис некорректен"
    sudo mv "$BACKUP" "$NGINX_CONF"
    rm -f /tmp/nginx.conf.new
    exit 1
fi
