# Cat Shelter Docker Commands

.PHONY: help build up down logs clean test

help: ## Show this help message
	@echo "Cat Shelter Management System"
	@echo "Available commands:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## Build all Docker images
	docker-compose build

up: ## Start all services in development mode
	docker-compose up -d

up-logs: ## Start all services and follow logs
	docker-compose up

down: ## Stop all services
	docker-compose down

restart: ## Restart all services
	docker-compose restart

logs: ## View logs from all services
	docker-compose logs -f

logs-api: ## View logs from backend API only
	docker-compose logs -f data_api

logs-frontend: ## View logs from frontend only
	docker-compose logs -f frontend

logs-compiler: ## View logs from data compiler only
	docker-compose logs -f data_compiler

clean: ## Remove containers, networks, and volumes
	docker-compose down -v --remove-orphans
	docker system prune -f

clean-all: ## Remove everything including images
	docker-compose down -v --rmi all --remove-orphans
	docker system prune -af

prod: ## Run in production mode
	docker-compose --profile production up -d

prod-build: ## Build and run in production mode
	docker-compose --profile production up -d --build

test: ## Run tests
	docker-compose run --rm data_api mix test
	docker-compose run --rm data_compiler mix test
	docker-compose run --rm frontend npm run test:run

shell-api: ## Access backend shell
	docker-compose exec data_api /bin/bash

shell-frontend: ## Access frontend shell
	docker-compose exec frontend /bin/sh

shell-compiler: ## Access data compiler shell
	docker-compose exec data_compiler /bin/bash

db-reset: ## Reset database
	docker-compose exec data_api mix ecto.reset

db-migrate: ## Run database migrations
	docker-compose exec data_api mix ecto.migrate

db-seed: ## Seed database
	docker-compose exec data_api mix run priv/repo/seeds.exs

compile-config: ## Compile and store shelter configuration in Redis
	docker-compose exec data_compiler mix run -e "json = File.read!(\"shelter_config.json\"); DataCompiler.process_input(json); IO.puts(\"✅ Shelter configuration compiled and stored in Redis\")"

status: ## Show running containers
	docker-compose ps