# Документация тестирования Calista

## 1. Обзор стратегии тестирования

Проект Calista спроектирован с упором на надежность, проверяемость бизнес-правил и соответствие критериям ПМ07.

Тестирование охватывает:
* **Unit-тесты**: изолированная проверка валидаторов, логики локального поиска и многофакторной фильтрации, правил вместимости команд и жизненного цикла заявок.
* **Widget-тесты**: тестирование отображения пользовательского интерфейса, состояний кнопок, текстовых полей, карточек проектов и чипов категорий.

---

## 2. Результаты выполненных тестов

Все тесты были фактически запущены через Flutter Test Runner:

```bash
flutter test
```

Результат выполнения:
```text
00:00 +0: test/unit/project_filter_test.dart: Search filters correctly by title case-insensitive
00:00 +1: test/unit/project_filter_test.dart: Search filters correctly by skills
00:00 +2: test/unit/project_filter_test.dart: Filter by Category isolates correct category
00:00 +3: test/unit/project_filter_test.dart: Filter by Team Capacity ranges works accurately
00:00 +4: test/unit/project_filter_test.dart: Filter by upcoming deadline within 30 days
00:00 +5: test/unit/team_capacity_and_application_rules_test.dart: Project detects full capacity
00:00 +6: test/unit/team_capacity_and_application_rules_test.dart: Project detects expired deadline
00:00 +7: test/unit/team_capacity_and_application_rules_test.dart: Open project can accept applications
00:00 +8: test/unit/team_capacity_and_application_rules_test.dart: ProjectApplication status flags
00:00 +9: test/unit/validators_test.dart: validateName correctly checks non-empty and minimum length
00:00 +10: test/unit/validators_test.dart: validateEmail validates RFC compliant email addresses
00:00 +11: test/unit/validators_test.dart: validatePassword requires at least 8 characters
00:00 +12: test/unit/validators_test.dart: validateConfirmPassword checks matching passwords
00:00 +13: test/unit/validators_test.dart: validateTelegram checks format and normalizes @ sign
00:00 +14: test/unit/validators_test.dart: validateProfileSkills requires at least 2 skills
00:00 +15: test/unit/validators_test.dart: validateProjectTitle enforces 5-80 characters
00:00 +16: test/unit/validators_test.dart: validateProjectDescription enforces 20-2000 characters
00:00 +17: test/unit/validators_test.dart: validateMaxMembers enforces 2 to 8 members and respect current count
00:00 +18: test/unit/validators_test.dart: validateDeadline allows only future dates
00:00 +19: test/unit/validators_test.dart: validateProjectSkills requires at least 1 skill
00:00 +20: test/unit/validators_test.dart: validateApplicationMessage limits message to 300 characters
00:00 +21: test/widget/project_card_widget_test.dart: ProjectCard renders details and responds to interactions
00:01 +22: test/widget/ui_components_widget_test.dart: AppButton handles tap and loading state
00:01 +23: test/widget/ui_components_widget_test.dart: AppTextField shows label and enters text
00:02 +24: test/widget/ui_components_widget_test.dart: EmptyState displays title and action
00:02 +25: test/widget/ui_components_widget_test.dart: ErrorState displays message and retry action
00:02 +26: test/widget/ui_components_widget_test.dart: CategoryChip and SkillChip respond to tap
00:02 +27: All tests passed!
```

---

## 3. Детализация наборов тестов

### 3.1. `test/unit/validators_test.dart`
* Валидация имени и фамилии (не пустое, минимум 2 символа).
* Валидация электронной почты (RFC-регулярное выражение).
* Валидация пароля (минимум 8 символов).
* Совпадение паролей при регистрации.
* Валидация Telegram username (нормализация префикса `@`, допустимые символы, длина 5–32).
* Минимальное количество навыков профиля (не менее 2).
* Длина названия проекта (5–80 символов).
* Длина описания проекта (20–2000 символов).
* Ограничение вместимости команды (2–8 человек) и запрет уменьшать вместимость ниже текущего числа участников.
* Проверка дедлайна (только будущая дата).
* Ограничение длины комментария к заявке (до 300 символов).

### 3.2. `test/unit/project_filter_test.dart`
* Полнотекстовый регистронезависимый поиск по названию, описанию, категории и навыкам.
* Фильтрация по фиксированным категориям.
* Фильтрация по диапазонам вместимости (`2-3`, `4-5`, `6+`).
* Фильтрация по дедлайну (ближайшие 30 дней).

### 3.3. `test/unit/team_capacity_and_application_rules_test.dart`
* Переход проекта в состояние `isFull` при достижении `memberCount >= maxMembers`.
* Проверка истечения дедлайна `isDeadlineExpired`.
* Статусы и текстовые метки сущности `ProjectApplication` (`pending`, `accepted`, `rejected`, `cancelled`).

### 3.4. `test/widget/project_card_widget_test.dart`
* Отрисовка всех параметров карточки: название, описание, категория, навыки, дедлайн, счётчик участников.
* Проверка обработки нажатия на карточку (навигация в детали).
* Проверка интерактивного переключения закладки избранного.

### 3.5. `test/widget/ui_components_widget_test.dart`
* Состояния кнопки `AppButton` (активное, выключенное, индикатор загрузки).
* Поле ввода `AppTextField` (валидация, ввод текста).
* Компоненты пустых состояний `EmptyState` и ошибок `ErrorState`.
* Интерактивные чипы `CategoryChip` и `SkillChip`.

---

## 4. Инструкция по запуску тестирования

Проверка статического анализатора (0 предупреждений):
```bash
flutter analyze
```

Запуск автоматических тестов:
```bash
flutter test
```
