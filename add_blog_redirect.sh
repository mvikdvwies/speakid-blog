#!/bin/bash
# Скрипт для добавления 301 редиректа с blog.speakid.ru на speakid.ru/blog/

BACKUP="/etc/nginx/nginx.conf.backup.$(date +%Y%m%d_%H%M%S)"
cp /etc/nginx/nginx.conf "$BACKUP"

SSL_CERT="/etc/ssl/certs/speakid.ru.crt"
SSL_KEY="/etc/ssl/private/speakid.ru.key"

# Находим номер строки первого server { перед server_name speakid.ru
SERVER_START=$(awk "/^[[:space:]]*server[[:space:]]*\{/ {start=NR; next} start && NR <= start+10 && /server_name speakid.ru/ {print start; exit}" /etc/nginx/nginx.conf)

if [ -z "$SERVER_START" ]; then
    echo "✗ Не найден server блок для speakid.ru"
    exit 1
fi

echo "Найден server блок на строке $SERVER_START"

# Создаём временный файл с блоком редиректа
cat > /tmp/redirect_block.txt << 'BLOCK'
	# Редирект с blog.speakid.ru на speakid.ru/blog/
	server {
		listen 443 ssl http2;
		server_name blog.speakid.ru;
		ssl_certificate /etc/ssl/certs/speakid.ru.crt;
		ssl_certificate_key /etc/ssl/private/speakid.ru.key;
		return 301 https://speakid.ru/blog$request_uri;
	}
	
	server {
		listen 80;
		server_name blog.speakid.ru;
		return 301 https://speakid.ru/blog$request_uri;
	}
	
BLOCK

# Вставляем блок перед найденной строкой
sed -i "${SERVER_START}r /tmp/redirect_block.txt" /etc/nginx/nginx.conf

if nginx -t 2>/dev/null; then
    if systemctl reload nginx; then
        echo "✓ Готово! Редирект настроен. Backup: $BACKUP"
        rm -f /tmp/redirect_block.txt
    else
        mv "$BACKUP" /etc/nginx/nginx.conf
        rm -f /tmp/redirect_block.txt
        echo "✗ Ошибка перезагрузки, откат выполнен"
        exit 1
    fi
else
    mv "$BACKUP" /etc/nginx/nginx.conf
    rm -f /tmp/redirect_block.txt
    echo "✗ Ошибка синтаксиса, откат выполнен"
    exit 1
fi
