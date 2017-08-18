defmodule FastGlobal do
  @moduledoc """
  Abuse module constant pools as a "read-only shared heap" (since erts 5.6)
  http://www.erlang.org/pipermail/erlang-questions/2009-March/042503.html
  """

  @type t :: {__MODULE__, atom}

  @doc """
  Create a module for the FastGlobal instance.
  """
  @spec new(atom) :: {__MODULE__, atom}
  def new(key) do
    {__MODULE__, key_to_module(key)}
  end

  @doc """
  Get the value for `key` or return nil.
  """
  @spec get(atom) :: any | nil
  def get(key), do: get(key, nil)

  @doc """
  Get the value for `key` or return `default`.
  """
  @spec get(atom | {__MODULE__, module}, any) :: any
  def get({__MODULE__, module}, default), do: do_get(module, default)
  def get(key, default), do: key |> key_to_module |> do_get(default)

  @doc """
  Store `value` at `key`, replaces an existing value if present.
  """
  @spec put(atom | {__MODULE__, module}, any) :: :ok
  def put({__MODULE__, module}, value), do: do_put(module, value)
  def put(key, value), do: key |> key_to_module |> do_put(value)

  @doc """
  Delete value stored at `key`, no-op if non-existent.
  """
  @spec delete(atom | {__MODULE__, module}) :: :ok
  def delete({__MODULE__, module}), do: do_delete(module)
  def delete(key), do: key |> key_to_module |> do_delete

  ## Private

  @spec do_get(atom, any) :: any
  defp do_get(module, default) do
    try do
      module.value
    catch
      :error, :undef ->
        default
    end
  end

  @spec do_put(atom, any) :: :ok
  defp do_put(module, value) do
    binary = compile(module, value)
    :code.purge(module)
    {:module, ^module} = :code.load_binary(module, '#{module}.erl', binary)
    :ok
  end

  @spec do_delete(atom) :: :ok
  defp do_delete(module) do
    :code.purge(module)
    :code.delete(module)
  end

  @spec key_to_module(atom) :: atom
  defp key_to_module(key) do
    # Don't use __MODULE__ because it is slower.
    :"Elixir.FastGlobal.#{key}"
  end

  @spec compile(atom, any) :: binary
  defp compile(module, value) do
    {:ok, ^module, binary} =
      module
      |> value_to_abstract(value)
      |> :compile.forms([:verbose, :report_errors])

    binary
  end

  @spec value_to_abstract(atom, any) :: [:erl_syntax.syntaxTree]
  defp value_to_abstract(module, value) do
    [
      {:attribute, 0, :module, module},
      {:attribute, 0, :export, [value: 0]},
      {:function, 0, :value, 0, [{:clause, 0, [], [], [:erl_syntax.revert(:erl_syntax.abstract(value))]}]}
    ]
  end
end
