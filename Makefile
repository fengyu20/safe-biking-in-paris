# Makefile - Simplified version for Safe Biking in Paris project
.PHONY: help setup build up down logs clean infra ingest transform check-docker check-credentials


# Check prerequisites
check-docker:
	@echo "🔍 Checking Docker..."
	@which docker > /dev/null || (echo "❌ Docker not found! Please install Docker." && exit 1)
	@which docker-compose > /dev/null || (echo "❌ Docker Compose not found!" && exit 1)
	@echo "✅ Docker is ready"

check-credentials:
	@echo "🔍 Checking credentials..."
	@test -f credentials.json || (echo "❌ credentials.json not found! Please add your Google Cloud credentials." && exit 1)
	@echo "✅ Credentials found"

# Setup
setup: check-docker check-credentials
	@echo "✅ Setup complete!"

# Build Docker images
build: check-docker
	@echo "🔨 Building Docker images..."
	docker-compose build

# Infrastructure setup
infra: check-docker check-credentials
	@echo "🏗️ Setting up infrastructure..."
	docker-compose up --no-deps --build infra

# Data ingestion
ingest: check-docker check-credentials
	@echo "📥 Running data ingestion..."
	docker-compose run --rm ingestion

# Data transformation
transform: check-docker check-credentials
	@echo "🔄 Running data transformations..."
	docker-compose run --rm dbt

# Run complete pipeline
up: setup build
	@echo "🚀 Running complete pipeline..."
	docker-compose up --build infra
	docker-compose run --rm ingestion
	docker-compose run --rm dbt

# Stop containers
down: check-docker
	@echo "🛑 Stopping containers..."
	docker-compose down

# Show logs
logs: check-docker
	@echo "📋 Showing logs..."
	docker-compose logs -f

# Clean up
clean: down
	@echo "🧹 Cleaning up..."
	docker-compose down --rmi all --volumes --remove-orphans
	docker system prune -f
