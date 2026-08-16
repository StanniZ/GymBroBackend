# GymBro Backend

Первый рабочий каркас backend для GymBro:

- FastAPI API;
- PostgreSQL;
- SQLAlchemy 2;
- Alembic migrations;
- Docker Compose;
- начальные таблицы `users` и `auth_identities`;
- endpoint `GET /health`.

## Требования

- Docker Desktop с Docker Compose.

## Первый запуск

```bash
cp .env.example .env
docker compose up --build
```

После запуска:

- API: <http://localhost:8000>
- Swagger: <http://localhost:8000/docs>
- Health check: <http://localhost:8000/health>

Проверка health endpoint:

```bash
curl http://localhost:8000/health
```

Ожидаемый ответ:

```json
{
  "status": "ok",
  "service": "gymbro-backend"
}
```

## Тесты

При запущенной базе:

```bash
docker compose run --rm api pytest
```

## Миграции базы

При запуске контейнера API команда `alembic upgrade head` применяется
автоматически. Для ручного запуска:

```bash
docker compose run --rm api alembic upgrade head
```

Создание следующей миграции после изменения моделей:

```bash
docker compose run --rm api alembic revision --autogenerate -m "describe change"
```

## Текущая модель авторизации

Таблица `users` хранит внутренний аккаунт GymBro. Таблица
`auth_identities` связывает его с внешним провайдером авторизации. Для Apple
поля будут выглядеть так:

```text
provider = "apple"
provider_user_id = значение claim "sub" из проверенного Apple identity token
```

Пароль Apple и настоящий Apple ID пользователя в базе не сохраняются.

## Следующий этап

Добавить `POST /auth/apple`: принять `identityToken` и `authorizationCode`,
проверить их сервером, найти или создать пользователя и вернуть собственную
сессию GymBro.
