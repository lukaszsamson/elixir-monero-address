# MoneroAddress

Library for decoding and validating Monero addresses.

## Installation

The package can be installed
by adding `monero_address` to your list of dependencies in `mix.exs`.
You also need to override `sha3` dependancy as the compatible version `1.0.0`
no longer compiles and the current version `2.0.0` uses not compatible official sha3.

```elixir
def deps do
  [
    {:monero_address, "~> 1.0.0"},
    {:sha3, github: "lukaszsamson/erlang-sha3", branch: "develop", override: true},
  ]
end
```

## Usage

```elixir
MoneroAddress.decode_address!(address)
```

## Documentation

Docs can be found at [https://hexdocs.pm/monero_address](https://hexdocs.pm/monero_address).

## License

MoneroAddress source code is released under MIT License.
Check LICENSE file for more information.
