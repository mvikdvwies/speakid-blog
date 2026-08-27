#!/bin/bash
# Полный деплой блога: структура, все статьи, новые/обновлённые изображения
# Использование: ./deploy-full.sh

set -euo pipefail

BLOG="$(cd "$(dirname "$0")" && pwd)"
exec "$BLOG/deploy.sh" \
  _config.yml \
  index.md \
  sitemap.xml \
  metodika.md \
  igry.md \
  dohod.md \
  onlajn-rabota.md \
  _data/articles.yml \
  _data/categories.yml \
  _includes/article-card.html \
  _includes/article-cards.html \
  _includes/breadcrumbs.html \
  _includes/category-nav.html \
  _includes/cta-speakid.html \
  _includes/head.html \
  _layouts/category.html \
  _layouts/home.html \
  _layouts/post.html \
  assets/style.css \
  posts/classroom-phrases-with-tpr-for-kids.md \
  posts/common-teachers-mistakes.md \
  posts/english-games-online.md \
  posts/faq-tpr-english-for-kids.md \
  posts/first-article-new.md \
  posts/five-ideas-for-warmup-stage.md \
  posts/free-tools-for-online-esl-lessons.md \
  posts/how-to-build-schedule-without-burnout.md \
  posts/how-to-find-students-online.md \
  posts/how-to-increase-prices-for-lessons.md \
  posts/how-to-reduce-lesson-cancellations.md \
  posts/lessons-for-kids-online.md \
  posts/seven-signs-student-will-quit.md \
  posts/speakid-vs-ordinary-lessons.md \
  posts/utp.md \
  posts/why-emotions-matter-in-lessons-emotional-attachment.md \
  posts/trial-lesson-25-minutes-script.md \
  posts/how-much-to-charge-for-english-lessons-kids.md \
  posts/child-silent-online-english-lesson.md \
  posts/how-to-message-parents-whatsapp.md \
  images/english-games-online.PNG \
  images/lessons-for-kids-online.PNG \
  images/trial-lesson-25-minutes-script.png \
  images/how-much-to-charge-for-english-lessons-kids.png \
  images/how-much-to-charge-invisible-work.png \
  images/how-much-to-charge-mini-group.png \
  images/child-silent-online-english-lesson.png \
  images/child-silent-safe-choice.png \
  images/child-silent-parent-step-back.png \
  images/how-to-message-parents-whatsapp.png \
  images/parent-whatsapp-boundaries.png \
  images/parent-whatsapp-progress-report.png
