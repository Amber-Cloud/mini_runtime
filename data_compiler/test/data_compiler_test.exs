defmodule DataCompilerTest do
  use ExUnit.Case
  doctest DataCompiler

  test "greets the world" do
    assert DataCompiler.hello() == :world
  end
end
