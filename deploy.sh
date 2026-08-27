#!/bin/bash
# Деплой блога на speakid.ru/blog
# Использование: ./deploy.sh [файлы...]  — залить файлы и пересобрать
#                ./deploy.sh --build-only — только jekyll build на сервере

set -euo pipefail

BLOG="$(cd "$(dirname "$0")" && pwd)"
SERVER="root@185.179.190.242"
REMOTE="/opt/speakid-blog"

build() {
  ssh "$SERVER" "cd $REMOTE && chmod -R a+rX . && docker run --rm -v $REMOTE:/srv/jekyll -w /srv/jekyll jekyll/jekyll:pages jekyll build"
}

if [[ "${1:-}" == "--build-only" ]]; then
  build
  exit 0
fi

if [[ $# -gt 0 ]]; then
  for f in "$@"; do
    rel="${f#"$BLOG"/}"
    case "$rel" in
      posts/*) scp "$BLOG/$rel" "$SERVER:$REMOTE/posts/" ;;
      images/*) scp "$BLOG/$rel" "$SERVER:$REMOTE/images/" ;;
      assets/*) scp "$BLOG/$rel" "$SERVER:$REMOTE/assets/" ;;
      _includes/*) scp "$BLOG/$rel" "$SERVER:$REMOTE/_includes/" ;;
      _layouts/*) scp "$BLOG/$rel" "$SERVER:$REMOTE/_layouts/" ;;
      _data/*)
        ssh "$SERVER" "mkdir -p $REMOTE/_data"
        scp "$BLOG/$rel" "$SERVER:$REMOTE/_data/"
        ;;
      index.md|sitemap.xml|_config.yml|robots.txt|metodika.md|igry.md|dohod.md|onlajn-rabota.md)
        scp "$BLOG/$rel" "$SERVER:$REMOTE/" ;;
      *) echo "Неизвестный путь: $rel" >&2; exit 1 ;;
    esac
  done
fi

build
echo "OK: https://speakid.ru/blog/"
