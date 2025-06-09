# Makefile for Safe Biking in Paris - Data Pipeline

# Variables
DC := docker compose
PRECHECK := check-docker check-credentials

# Phony targets
.PHONY: help setup build up infra ingest transform eda down logs clean clean-docker clean-infra clean-all

## Default help output
help:
	@echo "Safe Biking in Paris - Data Pipeline"
	@echo
	@echo "Setup & Run:"
	@echo "  make setup       - Check prerequisites"
	@echo "  make build       - Build Docker images"
	@echo "  make up          - Run full pipeline (infra, ingest, transform, EDA)"
	@echo "  make infra       - Provision cloud infrastructure"
	@echo "  make ingest      - Execute data ingestion"
	@echo "  make transform   - Execute data transformations"
	@echo "  make eda         - Launch Jupyter for EDA"
	@echo "  make ml          - Launch Jupyter for ML"
	@echo
	@echo "Cleanup (Use with caution):"
	@echo "  make down        - Stop all containers"
	@echo "  make clean-docker - Remove Docker resources"
	@echo "  make clean-infra  - Destroy cloud infrastructure"
	@echo "  make clean-all    - Full cleanup (Docker + Cloud)"
	@echo "  make clean        - Alias for clean-docker (safe default)"
	@echo
	@echo "Other:"
	@echo "  make logs        - Tail container logs"

## Prerequisite checks
define _check_cmd
	@echo "Checking $(1)..."
	@which $(1) > /dev/null || (echo "$(1) not found! Please install $(1)." && exit 1)
	@echo "$(1) is available"
endef

check-docker:
	$(call _check_cmd,docker)
	@echo "Checking docker compose..."
	@docker compose version > /dev/null || (echo "docker compose not found! Please install Docker Desktop." && exit 1)
	@echo "docker compose is available"

check-credentials:
	@echo "Checking credentials..."
	@test -f credentials.json \
		|| (echo "credentials.json not found! Add your Google Cloud credentials." && exit 1)
	@echo "Credentials found"

## Setup & build
setup: $(PRECHECK)
	@echo "Setup complete!"

build: check-docker
	@echo "Building Docker images..."
	@$(DC) build

infra: $(PRECHECK)
	@echo "Provisioning infrastructure..."
	@$(DC) up --no-deps --build infra

ingest: $(PRECHECK)
	@echo "Running data ingestion..."
	@$(DC) run --rm ingestion

transform: $(PRECHECK)
	@echo "Running data transformations..."
	@$(DC) run --rm dbt

eda: $(PRECHECK)
	@echo "Starting Jupyter for EDA..."
	@echo "Access at: http://localhost:8888 (notebook: eda.ipynb)"
	@$(DC) run --rm --service-ports eda

ml: $(PRECHECK)
	@echo "Starting Jupyter for ML..."
	@echo "Access at: http://localhost:8800 (notebook: ml.ipynb)"
	@$(DC) run --rm --service-ports ml

## Full pipeline
up: setup build
	@echo "Running full pipeline..."
	@echo "It may take a few minutes to build the infrastructure..."
	@$(DC) up --build infra
	@$(DC) run --rm ingestion
	@$(DC) run --rm dbt
	@echo "Executing EDA notebook..."
	@$(DC) run --rm eda jupyter nbconvert --execute eda.ipynb --to html --output-dir=/app/analysis
	@echo "Pipeline complete! Results in 'analysis/'"
	@echo "Executing ML notebook..."
	@$(DC) run --rm ml jupyter nbconvert --execute ml.ipynb --to html --output-dir=/app/ml_output

## Utilities
down: check-docker
	@echo "Stopping containers..."
	@$(DC) down

logs: check-docker
	@echo "Tailing logs..."
	@$(DC) logs -f

## Cleanup targets
clean-docker: down
	@echo "Removing Docker resources..."
	@$(DC) down --rmi all --volumes --remove-orphans
	@docker system prune -f
	@echo "Docker cleanup done"

clean-infra: $(PRECHECK)
	@echo "Destroying cloud infrastructure!"
	@echo "This will remove BigQuery datasets, GCS buckets, service accounts, IAM bindings."
	@read -p "Type 'yes' to confirm: " conf \
		&& [ "$${conf}" = "yes" ] \
		|| (echo "Cancelled." && exit 1)
	@$(DC) run --rm infra destroy -auto-approve
	@echo "Infrastructure destroyed"

clean-all: clean-infra clean-docker
	@echo "Full cleanup complete"

clean: clean-docker