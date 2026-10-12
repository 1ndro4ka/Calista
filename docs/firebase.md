# Архитектура и интеграция Firebase в Calista

## 1. Обзор сервисов

Приложение Calista использует Firebase как полноценный серверный бэкенд:
* **Firebase Authentication** — управление учётными записями студентов (Email + Password).
* **Cloud Firestore** — хранение реляционно-структурированных документов NoSQL.
* **Firebase Storage** — облачное хранение фотографий профилей пользователей.

---

## 2. Схема коллекций Cloud Firestore

### Коллекция `users`
Путь: `/users/{uid}`

| Поле | Тип | Описание |
| :--- | :--- | :--- |
| `uid` | String | Уникальный идентификатор из Firebase Auth |
| `firstName` | String | Имя студента |
| `lastName` | String | Фамилия студента |
| `telegramUsername` | String | Имя пользователя Telegram (без `@`) |
| `avatarUrl` | String? | Ссылка на аватар в Firebase Storage |
| `bio` | String? | Описание о себе (до 300 символов) |
| `course` | int? | Курс обучения (1–5) |
| `specialty` | String? | Специальность/направление обучения |
| `skills` | List\<String\> | Список навыков (минимум 2) |
| `createdAt` | Timestamp | Дата создания аккаунта |
| `updatedAt` | Timestamp | Дата последнего обновления |

#### Подколлекция Избранного: `/users/{uid}/favorites/{projectId}`
Хранит ID проектов, добавленных студентом в закладки.

---

### Коллекция `projects`
Путь: `/projects/{projectId}`

| Поле | Тип | Описание |
| :--- | :--- | :--- |
| `ownerId` | String | UID создателя проекта |
| `title` | String | Название проекта (5–80 символов) |
| `description` | String | Подробное описание (20–2000 символов) |
| `category` | String | Категория (Разработка, Дизайн и др.) |
| `requiredSkills` | List\<String\> | Необходимые навыки (минимум 1) |
| `maxMembers` | int | Максимальный размер команды (2–8) |
| `memberCount` | int | Текущее число участников (начинается с 1) |
| `deadline` | Timestamp | Дедлайн набора команды (будущая дата) |
| `createdAt` | Timestamp | Время создания |
| `updatedAt` | Timestamp | Время обновления |
| `status` | String | `'open'` (открыт), `'full'` (набран), `'closed'` (закрыт) |

---

### Коллекция `project_members`
Путь: `/project_members/{projectId}_{userId}`

| Поле | Тип | Описание |
| :--- | :--- | :--- |
| `projectId` | String | ID проекта |
| `userId` | String | UID участника |
| `role` | String | `'owner'` (создатель) или `'member'` (участник) |
| `joinedAt` | Timestamp | Время вступления |
| `userName` | String | Денормализованное имя для быстрого отображения |
| `userTelegram` | String | Telegram username |
| `userSkills` | List\<String\> | Навыки участника |
| `userAvatarUrl` | String? | Аватар участника |

---

### Коллекция `applications`
Путь: `/applications/{projectId}_{applicantId}`  
*(Детерминированный ID документа гарантирует отсутствие дублирующих заявок от одного кандидата)*

| Поле | Тип | Описание |
| :--- | :--- | :--- |
| `projectId` | String | ID проекта |
| `projectTitle` | String | Название проекта |
| `applicantId` | String | UID кандидата |
| `applicantName` | String | Полное имя кандидата |
| `applicantTelegram`| String | Telegram username кандидата |
| `applicantSkills` | List\<String\> | Навыки кандидата |
| `applicantAvatarUrl`| String? | Аватар кандидата |
| `message` | String? | Комментарий к заявке (до 300 символов) |
| `status` | String | `'pending'`, `'accepted'`, `'rejected'`, `'cancelled'` |
| `createdAt` | Timestamp | Время подачи заявки |
| `reviewedAt` | Timestamp? | Время рассмотрения владельцем |

---

### Коллекция `notifications`
Путь: `/notifications/{notificationId}`

| Поле | Тип | Описание |
| :--- | :--- | :--- |
| `recipientId` | String | UID получателя |
| `type` | String | `'application_received'`, `'application_accepted'`, `'application_rejected'`, `'member_left'` |
| `title` | String | Заголовок уведомления |
| `body` | String | Текст уведомления |
| `projectId` | String? | Связанный проект |
| `applicationId`| String? | Связанная заявка |
| `isRead` | bool | Статус прочтения |
| `createdAt` | Timestamp | Время генерации |

---

## 3. Транзакции и Batched Writes

Все критические операции с данными выполняются атомарно:
1. **Принятие заявки (`acceptApplication`)**:
   В рамках единой `Firestore.runTransaction`:
   * Проверяется наличие свободных мест (`memberCount < maxMembers`).
   * Заявка переводится в статус `'accepted'`.
   * Создаётся запись участника в `project_members`.
   * Инкрементируется `memberCount`.
   * Если свободных мест не осталось, статус проекта меняется на `'full'`.
   * Формируется уведомление кандидату.
2. **Создание проекта (`createProject`)**:
   Через `Firestore.batch`:
   * Создаётся документ проекта со счётчиком участников 1.
   * Создаётся документ создателя с ролью `'owner'` в `project_members`.
3. **Удаление проекта (`deleteProject`)**:
   Через `Firestore.batch`:
   * Удаляется сам проект.
   * Удаляются все связанные записи участников.
   * Удаляются все связанные заявки.
4. **Выход участника (`leaveProject`)**:
   В транзакции удаляется membership, декрементируется `memberCount`, статус проекта возвращается в `'open'`, создателю отправляется уведомление.

---

## 4. Настройка реального Firebase проекта

Для подключения приложения к вашему проекту в Firebase Console:
1. Установите Firebase CLI: `npm install -g firebase-tools`
2. Авторизуйтесь: `firebase login`
3. Установите FlutterFire CLI: `dart pub global activate flutterfire_cli`
4. В корне проекта Calista выполните команду:
   ```bash
   flutterfire configure
   ```
5. В консоли Firebase включите:
   * **Authentication**: метод входа **Email/Password**.
   * **Cloud Firestore**: в режиме Production.
   * **Firebase Storage**: в режиме Production.
6. Разверните подготовленные правила безопасности и индексы:
   ```bash
   firebase deploy --only firestore:rules,firestore:indexes,storage
   ```
