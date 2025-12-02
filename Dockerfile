# ---------- Stage 1: Build & install dependencies ----------
FROM python:3.9 AS builder

WORKDIR /app

# System deps needed for mysqlclient while building wheels
RUN apt-get update && apt-get install -y \
    gcc \
    default-libmysqlclient-dev \
    pkg-config \
  && rm -rf /var/lib/apt/lists/*

# Install Python dependencies
COPY requirement.txt .
RUN pip install --no-cache-dir -r requirement.txt

# Copy application code
COPY . .

# ---------- Stage 2: Runtime image ----------
FROM python:3.9-slim

WORKDIR /app

# System runtime deps for mysqlclient (no gcc needed here usually)
RUN apt-get update && apt-get install -y \
    default-libmysqlclient-dev \
    pkg-config \
  && rm -rf /var/lib/apt/lists/*

# Copy Python + installed packages from builder
COPY --from=builder /usr/local /usr/local

# Copy app code from builder
COPY --from=builder /app /app

EXPOSE 5000
CMD ["python", "app.py"]