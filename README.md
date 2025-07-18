# Mini-Runtime

A dynamic API system that generates endpoints based on configuration files, with an example cat shelter frontend application.

## Overview

This project demonstrates a mini-runtime system consisting of three main components:

- **DataCompiler** (Elixir) - Compiles JSON configurations and stores them in Redis
- **DataApi** (Elixir/Phoenix) - Dynamic API backend that reads configurations from Redis and serves endpoints
- **Runtime Client** (React/TypeScript) - Example frontend application (cat shelter) that consumes the API

## Demo

[📹 Watch Demo Video]()
[![Demo Video](https://img.youtube.com/vi/nPAKCew5I7k/maxresdefault.jpg)](https://youtu.be/nPAKCew5I7k)

_Click to watch the full demo showing filtering, cat pages, galleries, and responsive design_

## Quick Start

### Prerequisites

- Docker and Docker Compose
- Make (for convenience commands)

### Development Setup

```bash
# Build all services
make build

# Start all services (wait intil it's done)
make up

# Check status
make status
```

### Access Points

- **Cat Shelter Frontend**: http://localhost:3000
- **Data API**: http://localhost:4000
- **Example Data API Endpoint**: http://localhost:4000/api/shelter_app/cats

### Available Commands

```bash
make help              # Show all available commands
make build             # Build all Docker images
make up                # Start all services
make down              # Stop all services
make logs              # View logs from all services
make clean             # Remove containers and volumes
make status            # Show running containers
make seed              # Re-seed database manually
make compile-config    # Re-compile configuration manually
```

## Architecture

### Configuration Compiler (DataCompiler)

- **JSON Processing**: Compiles JSON configurations into standardized format
- **Redis Storage**: Stores compiled configurations in Redis for API consumption
- **Validation**: Ensures configuration integrity and type safety

### Dynamic API (DataApi)

- **Configuration-Driven**: Reads compiled configurations from Redis to serve endpoints
- **Database Agnostic**: Works with any PostgreSQL database schema
- **Multi-tenant**: Supports multiple applications with different configurations

### Cat Shelter Frontend (Runtime Client - example app)

- **React 19** with TypeScript
- **Cat Shelter Demo**: Shows how to consume the dynamic API
- **Modern CSS** with SCSS and BEM methodology
- **Responsive Design**: Mobile and desktop friendly

## Project Structure

```

├── data_compiler/
├── data_api/
├── runtime-client/ # Example frontend application
├── docker-compose.yml
├── Makefile
└── README.md

```

## Development

### Manual Development (without Docker)

Each service can be run independently:

**Data Compiler:**

```bash
cd data_compiler
mix deps.get
mix run -e "DataCompiler.process_input(File.read!(\"shelter_config.json\"))"
```

**API Backend:**

```bash
cd data_api
mix deps.get
mix ecto.setup
mix run priv/repo/seeds.exs  # Seeds database with example data
mix phx.server
```

_Note: For manual development, you'll also need PostgreSQL and Redis running locally, and the DataCompiler must have run to store configurations in Redis._

**Cat Shelter Frontend:**

```bash
cd runtime-client
npm install
npm run dev
```

## Testing

Each service has comprehensive test coverage:

```bash
# Backend tests
cd data_api && mix test

# Data compiler tests
cd data_compiler && mix test

# Frontend tests
cd runtime-client && npm run test:run
```

## Configuration

The system uses JSON configuration files that define:

- API endpoints and their database mappings
- Table schemas and column definitions
- Application-specific settings

Configuration changes are automatically compiled and stored in Redis when the system starts.

### Example Config

Can be found in `data_compiler/shelter_config.json`
