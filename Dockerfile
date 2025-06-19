# ------------------------------
# 🔧 Base image & environment
# ------------------------------
FROM python:3.12-slim-bookworm

# Set working directory
WORKDIR /app

# Environment variables
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1 \
    PIP_NO_CACHE_DIR=1 \
    PYTHONFAULTHANDLER=1 \
    REDIS_HOST=localhost \
    REDIS_PORT=6379 \
    PYTHON_ENV=production

# Install dependencies
RUN apt-get update && apt-get install -y --no-install-recommends \
    build-essential \
    curl \
    git \
    redis-server \
    supervisor \
    libglib2.0-0 \
    libnss3 \
    libnspr4 \
    libx11-6 \
    libxcomposite1 \
    libxdamage1 \
    libxrandr2 \
    libgbm1 \
    libasound2 \
    libatk1.0-0 \
    libatk-bridge2.0-0 \
    libxext6 \
    libxfixes3 \
    libxkbcommon0 \
    libdrm2 \
    libcups2 \
    libcairo2 \
    libpango-1.0-0 \
    libatspi2.0-0 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Copy project files
COPY . /app

# Install dependencies
COPY deploy/docker/requirements.txt .
RUN pip install --upgrade pip && pip install -r requirements.txt

# Optional: Install extra dependencies if needed
RUN pip install "/app[all]"

# Install and set up Playwright
RUN playwright install --with-deps

# Set ownership for appuser
RUN groupadd -r appuser && useradd -r -g appuser appuser && \
    chown -R appuser:appuser /app

USER appuser

# Expose Dokploy app port
EXPOSE 11235
EXPOSE 6379

# Start the app using supervisord
CMD ["supervisord", "-c", "supervisord.conf"]
