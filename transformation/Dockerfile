# transformation/Dockerfile
FROM python:3.9-slim

# Install git and dbt + the BigQuery adapter
RUN apt-get update && \
    apt-get install -y git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    pip install --no-cache-dir dbt-core dbt-bigquery

WORKDIR /app

COPY . .

ENTRYPOINT ["dbt"]
CMD ["run", "--profiles-dir", ".", "--project-dir", "."]