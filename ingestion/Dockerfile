FROM python:3.9-slim

WORKDIR /app

ARG CREDENTIALS_PATH=/app/credentials.json
ARG DEFAULT_PREFIX=raw

COPY . /app/
COPY requirements.txt /app/requirements.txt

RUN mkdir -p /app/infra

RUN pip install --no-cache-dir -r requirements.txt

ENV PYTHONPATH=/app
ENV GOOGLE_APPLICATION_CREDENTIALS=${CREDENTIALS_PATH}
ENV DEFAULT_PREFIX=${DEFAULT_PREFIX}

WORKDIR /app

ENTRYPOINT ["python", "ingest.py"]
CMD ["--gcs", "--prefix", "raw"] 