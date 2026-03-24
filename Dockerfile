# =========================
# Stage 1: Tailwind Build
# =========================
FROM node:20-alpine AS frontend

WORKDIR /build

# Initialize node project
RUN npm init -y

# Install Tailwind CSS
RUN npm install tailwindcss@3.4.0

# Create required structure
RUN mkdir -p src

# Create input.css
RUN echo "@tailwind base; @tailwind components; @tailwind utilities;" > src/input.css

# Initialize Tailwind config
RUN npx tailwindcss init

# Build Tailwind CSS
RUN npx tailwindcss -i ./src/input.css -o ./output.css --minify


# =========================
# Stage 2: Flask App
# =========================
FROM python:3.11-slim

WORKDIR /app

# Environment variables
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Install system dependencies
RUN apt-get update && apt-get install -y \
    build-essential \
    && rm -rf /var/lib/apt/lists/*

# Copy and install Python dependencies
COPY requirements.txt ./
RUN pip install --upgrade pip && \
    if [ -f requirements.txt ]; then pip install -r requirements.txt; fi

# Copy project files
COPY . .

# Create required directories inside container
RUN mkdir -p /app/app/static/css \
    && mkdir -p /app/app/templates \
    && mkdir -p /app/app/routes

# Copy built Tailwind CSS from Stage 1
COPY --from=frontend /build/output.css /app/app/static/css/output.css

# Expose internal container port
EXPOSE 5000

# Run Flask using Gunicorn (correct port)
CMD ["gunicorn", "-w", "4", "-b", "0.0.0.0:5000", "run:app"]