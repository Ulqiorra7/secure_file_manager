# ---- build stage ----
FROM python:3.12-slim AS builder

WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# ---- runtime stage ----
FROM python:3.12-slim

# создаём непривилегированного пользователя
RUN groupadd -r appuser && useradd -r -g appuser appuser

WORKDIR /app

# копируем только установленные пакеты из builder
COPY --from=builder /install /usr/local

# копируем код проекта
COPY --chown=appuser:appuser . .

# папка для файлов менеджера
RUN mkdir -p /app/storage && chown -R appuser:appuser /app/storage

USER appuser

ENV PYTHONUNBUFFERED=1
ENV STORAGE_DIR=/app/storage

CMD ["python", "main.py"]