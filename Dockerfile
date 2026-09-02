FROM python:3.12-slim AS base

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

WORKDIR /app

RUN groupadd --system gymbro \
    && useradd --system --gid gymbro --create-home gymbro

COPY requirements.txt ./

RUN pip install --no-cache-dir --upgrade pip \
    && pip install --no-cache-dir -r requirements.txt


FROM base AS development

COPY requirements-dev.txt ./

RUN pip install --no-cache-dir -r requirements-dev.txt

COPY --chown=gymbro:gymbro app ./app
COPY --chown=gymbro:gymbro tests ./tests
COPY --chown=gymbro:gymbro alembic ./alembic
COPY --chown=gymbro:gymbro alembic.ini ./

USER gymbro

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]


FROM base AS production

COPY --chown=gymbro:gymbro app ./app
COPY --chown=gymbro:gymbro alembic ./alembic
COPY --chown=gymbro:gymbro alembic.ini ./


USER gymbro

EXPOSE 8000

CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
