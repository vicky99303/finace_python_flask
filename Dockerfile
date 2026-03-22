# =========================
# Stage 1: Tailwind Build
# =========================
FROM node:20-alpine AS frontend

WORKDIR /build

# Init node project
RUN npm init -y

# Install Tailwind
RUN npm install tailwindcss@3.4.0

# Create required structure
RUN mkdir -p src

# Create input.css dynamically
RUN echo "@tailwind base; @tailwind components; @tailwind utilities;" > src/input.css

# Init config
RUN npx tailwindcss init

# Build CSS
RUN npx tailwindcss -i ./src/input.css -o ./output.css --minify


# =========================
# Stage 2: Flask App
# =========================
FROM python:3.11-slim

WORKDIR /app

ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install system deps (optional but useful)
RUN apt-get update && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements (if exists)
COPY requirements.txt ./

RUN pip install --upgrade pip && \
    if [ -f requirements.txt ]; then pip install -r requirements.txt; fi

# Copy project files
COPY . .

# Create required directories INSIDE container
RUN mkdir -p /app/app/static/css \
    && mkdir -p /app/app/templates \
    && mkdir -p /app/app/routes

# Copy Tailwind output
COPY --from=frontend /build/output.css /app/app/static/css/output.css

# Expose port
EXPOSE 5000

# Default Flask run (fallback if gunicorn not installed)
CMD ["sh", "-c", "gunicorn -w 4 -b 0.0.0.0:5000 run:app || python run.py"]