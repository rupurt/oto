# oto

Bulk SQL extraction over ODBC

## Usage

oto extract --dsn "" "SELECT * FROM people"

## Development

This project assumes you have already [installed nix](https://determinate.systems/posts/determinate-nix-installer)

1. Start a Nix devshell

```shell
nix develop -c $SHELL
```

2. Run the setup script

```shell
./scripts/setup
```

## License

`oto` is released under the [MIT license](./LICENSE)
