(function() {
  'use strict';

  function initCategoryFilter() {
    const filterButtons = document.querySelectorAll('.filter-btn');
    const articleCards = document.querySelectorAll('.article-card');

    if (filterButtons.length === 0 || articleCards.length === 0) {
      return;
    }

    filterButtons.forEach(button => {
      button.addEventListener('click', function() {
        const category = this.getAttribute('data-category');

        // Обновляем активную кнопку
        filterButtons.forEach(btn => btn.classList.remove('active'));
        this.classList.add('active');

        // Фильтруем карточки
        articleCards.forEach(card => {
          const cardCategory = card.getAttribute('data-category');
          const cardTags = card.getAttribute('data-tags') || '';

          let shouldShow = false;

          if (category === 'all') {
            shouldShow = true;
          } else {
            // Проверяем категорию
            const categoryMap = {
              'методика': ['методика', 'TPR', 'уроки английского', 'детские уроки', 'фразы для урока', 'ошибки учителей'],
              'игры': ['игры', 'игры для уроков', 'методика игр'],
              'доход': ['доход', 'доход учителя', 'УТП учителя'],
              'онлайн': ['онлайн обучение', 'онлайн английский', 'онлайн-работа']
            };

            const keywords = categoryMap[category] || [];
            const normalizedCardCategory = (cardCategory || '').toLowerCase();
            const normalizedCardTags = (cardTags || '').toLowerCase();

            // Проверяем точное совпадение категории (без учета регистра) или наличие ключевых слов в тегах
            const normalizedCategory = category.toLowerCase();
            const categoryMatch = {
              'методика': ['методика'],
              'игры': ['игры'],
              'доход': ['доход'],
              'онлайн': ['онлайн-работа', 'онлайн']
            };
            
            const categoryVariants = categoryMatch[normalizedCategory] || [normalizedCategory];
            
            shouldShow = categoryVariants.some(variant => 
              normalizedCardCategory.includes(variant.toLowerCase())
            ) || keywords.some(keyword => 
              normalizedCardCategory.includes(keyword.toLowerCase()) ||
              normalizedCardTags.includes(keyword.toLowerCase())
            );
          }

          // Показываем/скрываем карточку с анимацией
          if (shouldShow) {
            card.style.display = '';
            setTimeout(() => {
              card.style.opacity = '1';
              card.style.transform = 'scale(1)';
            }, 10);
          } else {
            card.style.opacity = '0';
            card.style.transform = 'scale(0.95)';
            setTimeout(() => {
              card.style.display = 'none';
            }, 200);
          }
        });
      });
    });

    // Инициализация стилей для анимации
    articleCards.forEach(card => {
      card.style.transition = 'opacity 0.2s ease, transform 0.2s ease';
      card.style.opacity = '1';
      card.style.transform = 'scale(1)';
    });
  }

  // Запускаем после загрузки DOM
  if (document.readyState === 'loading') {
    document.addEventListener('DOMContentLoaded', initCategoryFilter);
  } else {
    initCategoryFilter();
  }
})();

