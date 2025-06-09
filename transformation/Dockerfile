# transformation/Dockerfile
FROM python:3.9-slim

# Install git and dbt + the BigQuery adapter
RUN apt-get update && \
    apt-get install -y git && \
    apt-get clean && \
    rm -rf /var/lib/apt/lists/* && \
    pip install --no-cache-dir dbt-core dbt-bigquery

WORKDIR /app

# Copy requirements first for better caching
COPY packages.yml profiles.yml dbt_project.yml ./

# Install dbt dependencies
RUN dbt deps --profiles-dir . --project-dir .

# Copy the rest of the files
COPY . .

COPY scripts/build.sh /usr/local/bin/dbt-build
RUN chmod +x /usr/local/bin/dbt-build

ENTRYPOINT ["dbt"]
CMD ["build", "--profiles-dir", ".", "--project-dir", "."]