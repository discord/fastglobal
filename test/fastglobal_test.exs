defmodule FastGlobalTest do
  use ExUnit.Case

  test "put" do
    key = :put
    assert :ok == FastGlobal.put(key, :value)
    assert :value == FastGlobal.get(key)
  end

  test "delete" do
    key = :test_delete
    assert :ok == FastGlobal.put(key, :value)
    assert :value == FastGlobal.get(key)
    FastGlobal.delete(key)
    assert nil == FastGlobal.get(key)
  end

  test "getting never set value returns nil" do
    key = :never_set
    assert nil == FastGlobal.get(key)
  end
end
