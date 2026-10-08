# Contributing

## Reporting bugs and requesting features

Use [GitHub Issues](https://github.com/heroku-johnny/buildpack-elixir/issues).
Search before opening a new one — your issue may already be tracked.

## Pull requests

1. Fork the repository and create a branch from `main`
2. Make your changes
3. Run the test suite: `test/bats/bin/bats test/unit/`
4. Run the linter: `shellcheck bin/detect bin/compile bin/release bin/test bin/test-compile lib/*.sh`
5. Check formatting: `shfmt -d -i 2 -ci bin/detect bin/compile bin/release bin/test bin/test-compile lib/*.sh`
6. Open a pull request with a [conventional commit](https://www.conventionalcommits.org) title

## Commit message types

`feat`, `fix`, `chore`, `docs`, `test`, `refactor`, `ci`, `perf`

## Running tests locally

```bash
# Single stack
STACK=heroku-22 test/bats/bin/bats test/unit/

# All stacks
for stack in heroku-22 heroku-24 heroku-26; do
  STACK=$stack test/bats/bin/bats test/unit/
done
```

## License

By contributing, you agree to license your contribution under the [MIT License](LICENSE).
