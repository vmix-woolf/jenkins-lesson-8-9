FROM python:3.11-slim

# Вимикаємо створення .pyc файлів і буферизацію логів
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Створюємо робочу директорію всередині контейнера
WORKDIR /app

# Встановлюємо системні залежності для роботи з PostgreSQL
RUN apt-get update \
    && apt-get install -y --no-install-recommends gcc libpq-dev \
    && rm -rf /var/lib/apt/lists/*

# Копіюємо файл залежностей окремо для кращого кешування Docker
COPY requirements.txt .

# Встановлюємо Python-залежності
RUN pip install --no-cache-dir -r requirements.txt

# Копіюємо код Django-проєкту
COPY . .

# Відкриваємо порт Django
EXPOSE 8000

# Запускаємо Django-сервер
CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
