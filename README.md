# FastGlobal

[![Master](https://travis-ci.org/hammerandchisel/fastglobal.svg?branch=master)](https://travis-ci.org/hammerandchisel/fastglobal)
[![Hex.pm Version](http://img.shields.io/hexpm/v/fastglobal.svg?style=flat)](https://hex.pm/packages/fastglobal)

The Erlang VM is great at many things, but quick access to large shared data is not one of them. Storing data in a single process
results in overloading the process, using an ETS table gets more expensive to read as the data gets larger, and both require copying
data to the calling process. If you have large infrequently changing data that needs to be accessed by thousands of process there
is a better way.

Erlang has an optimization called constant pools for functions that return static data, you can also compile modules at runtime.
This method was originally popularized by [mochiglobal](https://github.com/mochi/mochiweb/blob/master/src/mochiglobal.erl). This
module is an Elixir version with some optimizations such as generating the atom keys and reusing them.

## Performance

```
benchmark name        iterations   average time
fastglobal get          10000000   0.35 µs/op
ets get                   500000   7.30 µs/op
agent get                 100000   12.82 µs/op
fastglobal put (5)           500   3986.32 µs/op
fastglobal put (10)          500   6723.91 µs/op
fastglobal put (100)          50   58144.80 µs/op
```

## Caveats

- Compile times get slower as data size increases.
- Getting a key that does not exist is expensive due to try/catch, put at least a `nil` value.
- Creating atoms from strings is not cheap, use `FastGlobal.new`.

## Usage

Add it to `mix.exs`

```elixir
defp deps do
  [{:fastglobal, "~> 1.0"}]
end
```

And just use it as a global map.

```elixir
data = %{
  a: 1,
  b: 2,
  c: [3, 4]
}
FastGlobal.put(:data, data)
data == FastGlobal.get(:data)
```

## License

FastGlobal is released under [the MIT License](LICENSE).
Check [LICENSE](LICENSE) file for more information.