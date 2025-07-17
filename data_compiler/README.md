# DataCompiler

Configuration compiler service that processes JSON application configurations and stores them in Redis for the DataApi to consume.

## Overview

DataCompiler takes JSON configuration files containing endpoint and table definitions, validates them, compiles them into an optimized format, and stores the result in Redis. The DataApi then reads these compiled configurations to dynamically serve API endpoints.

## Key Functions

- **JSON Processing**: Parses and validates JSON configuration files
- **Schema Validation**: Ensures table schemas and endpoints are properly defined
- **Redis Storage**: Stores compiled configurations using `config:{app_id}` keys
- **Error Handling**: Provides detailed error messages for invalid configurations

## Local Development

```bash
# Install dependencies
mix deps.get

# Compile configuration (requires Redis running)
mix run -e "DataCompiler.process_input(File.read!(\"shelter_config.json\"))"
```

*Note: Requires Redis running on localhost:6379 (or set REDIS_HOST/REDIS_PORT environment variables)*

## Testing

```bash
mix test
```

## Configuration Format

The compiler expects JSON files with the following structure:

```json
{
  "app_id": "your_app",
  "endpoints": [
    {
      "path": "/resource",
      "method": "GET", 
      "table": "table_name",
      "cardinality": "many"
    }
  ],
  "tables": {
    "table_name": {
      "name": "table_name",
      "columns": [
        {"name": "column_name", "type": "string"}
      ]
    }
  }
}
```

Supported column types: `integer`, `string`

