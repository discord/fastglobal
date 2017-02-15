defmodule FastGlobalTest do
  use ExUnit.Case

  test "get/put/delete" do
    key = "test"
    FastGlobal.delete(key)
    assert :bar == FastGlobal.get(key, :bar)
    FastGlobal.put(key, :baz)
    assert :baz == FastGlobal.get(key, :bar)
    FastGlobal.put(key, :moo)
    assert :moo == FastGlobal.get(key)
    FastGlobal.delete(key)
    assert :bar == FastGlobal.get(key, :bar)
    assert nil == FastGlobal.get(key)
  end
end
