defmodule EctoSecretSantaTest do
  use ExUnit.Case
  doctest EctoSecretSanta

  test "greets the world" do
    assert EctoSecretSanta.hello() == :world
  end
end
