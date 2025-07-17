# Cat Shelter Docker Commands

.PHONY: help build up down logs clean test seed compile-config status

help: ## Show this help message
	@echo "Cat Shelter Management System"
	@echo "Available commands:"
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "  %-15s %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## Build all Docker images
	docker-compose build

up: ## Start all services (auto-seeds and compiles config)
	docker-compose up -d

down: ## Stop all services
	docker-compose down

logs: ## View logs from all services
	docker-compose logs -f

clean: ## Remove containers and volumes
	docker-compose down -v

seed: ## Re-seed database manually
	docker-compose exec backend mix run priv/repo/seeds.exs

compile-config: ## Re-compile shelter configuration manually
	docker-compose exec data_compiler mix run -e "json = File.read!(\"shelter_config.json\"); DataCompiler.process_input(json); IO.puts(\"✅ Config compiled\")"

status: ## Show running containers
	docker-compose ps