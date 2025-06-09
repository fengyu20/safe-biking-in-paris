FROM python:3.9-slim

WORKDIR /app

# Install system dependencies for ML libraries and geospatial processing
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    libgomp1 \
    gdal-bin \
    libgdal-dev \
    libproj-dev \
    libgeos-dev \
    libspatialindex-dev \
    && rm -rf /var/lib/apt/lists/*

# Set GDAL environment variables
ENV GDAL_CONFIG=/usr/bin/gdal-config
ENV CPLUS_INCLUDE_PATH=/usr/include/gdal
ENV C_INCLUDE_PATH=/usr/include/gdal

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt

# Copy the entire project context (needed for imports)
COPY . .


# Set environment variables
ENV PYTHONUNBUFFERED=1
ENV PYTHONPATH="/app:${PYTHONPATH}"

# Create user and set permissions
RUN useradd -m -u 1000 ml_user && chown -R ml_user:ml_user /app
USER ml_user

EXPOSE 8800

CMD ["jupyter", "notebook", "--ip=0.0.0.0", "--port=8800", "--no-browser", "--allow-root", "--NotebookApp.token=''", "--NotebookApp.password=''"]