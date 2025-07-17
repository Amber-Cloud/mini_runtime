#!/usr/bin/env elixir

# Read and compile the shelter configuration
json = File.read!("shelter_config.json")
result = DataCompiler.process_input(json)

case result do
  {:ok, _} -> IO.puts("✅ Shelter configuration compiled and stored in Redis")
  {:error, reason} -> 
    IO.puts("❌ Failed to compile config: #{reason}")
    System.halt(1)
end