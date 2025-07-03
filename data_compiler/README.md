# DataCompiler

Compiles application configuration into a format suitable for DataAPI. Takes JSON input containing app configuration (app_id, endpoints, tables) and stores the compiled result in Redis for later retrieval.

## Prerequisites
- Redis running on localhost:6379

## Usage
```bash
mix deps.get
mix compile
mix test
```

