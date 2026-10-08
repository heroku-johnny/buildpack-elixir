# Elixir Buildpack for Heroku Stack >=22

A Heroku buildpack for [Elixir](https://elixir-lang.org) and [Erlang/OTP](https://www.erlang.org).
Supports stacks **heroku-22**, **heroku-24**, and **heroku-26**.

## Supported stacks and versions

| Stack | Ubuntu | OTP minimum | Elixir minimum |
|---|---|---|---|
| heroku-22 | 22.04 LTS | 24.2 | 1.12 |
| heroku-24 | 24.04 LTS | 24.3.4 | 1.12 |
| heroku-26 | 26.04 LTS | 26.0 | 1.15 |

OTP binaries are provided by [hex.pm builds](https://builds.hex.pm/builds/otp/).
Elixir binaries are provided by [hex.pm builds](https://builds.hex.pm/builds/elixir/).

## Usage

### 1. Set the buildpack

```bash
heroku buildpacks:set https://github.com/heroku-johnny/buildpack-elixir
```

### 2. Configure your app

Create `elixir_buildpack.config` in your project root. Both `erlang_version` and
`elixir_version` are required — the buildpack will not guess defaults.

```bash
erlang_version=27.2
elixir_version=v1.18.3
```

### 3. Deploy

```bash
git push heroku main
```

## Configuration reference

All options go in `elixir_buildpack.config` in the root of your repository.

| Option | Required | Default | Description |
|---|---|---|---|
| `erlang_version` | yes | — | Erlang/OTP version to install (e.g. `27.2`) |
| `elixir_version` | yes | — | Elixir version to install (e.g. `v1.18.3`) |
| `always_rebuild` | no | `false` | Set `true` to clear the build cache on every deploy |
| `release` | no | `false` | Set `true` to run `mix release --overwrite` after compile |
| `runtime_path` | no | `/app` | Path where Erlang and Elixir are installed at runtime |
| `hook_pre_fetch_dependencies` | no | — | Shell command to run before `mix deps.get` |
| `hook_pre_compile` | no | — | Shell command to run before `mix compile` |
| `hook_compile` | no | — | Shell command to replace `mix compile` entirely |
| `hook_post_compile` | no | — | Shell command to run after compile |

### Finding available versions

Browse available OTP versions for your stack:

- heroku-22 (ubuntu-22.04): https://builds.hex.pm/builds/otp/ubuntu-22.04/builds.txt
- heroku-24 (ubuntu-24.04): https://builds.hex.pm/builds/otp/ubuntu-24.04/builds.txt
- heroku-26 (ubuntu-26.04): https://builds.hex.pm/builds/otp/ubuntu-26.04/builds.txt

Browse available Elixir versions: https://builds.hex.pm/builds/elixir/builds.txt

## Hooks

Hooks are shell commands that run at specific points in the build pipeline. Set them
in `elixir_buildpack.config`. They run inside the build directory with `GIT_DIR` unset.

```bash
# Install Node.js assets before compile (Phoenix apps)
hook_pre_compile="npm run deploy --prefix assets"

# Run a custom compile command instead of mix compile
hook_compile="mix compile --warnings-as-errors"

# Run a script after compile
hook_post_compile="bash .buildpack/post_compile.sh"
```

If a hook command exits with a non-zero status, the build fails immediately with an
error message naming the hook and the command that failed.

## Mix releases

Set `release=true` to build a Mix release after compile:

```bash
erlang_version=27.2
elixir_version=v1.18.3
release=true
```

The buildpack runs `mix release --overwrite`. Your `mix.exs` must define a release
configuration. See the [Mix release docs](https://hexdocs.pm/mix/Mix.Tasks.Release.html).

## Heroku CI

This buildpack supports [Heroku CI](https://devcenter.heroku.com/articles/heroku-ci)
via the standard testpack API.

Set your test command in `app.json`:

```json
{
  "environments": {
    "test": {
      "buildpacks": [
        { "url": "https://github.com/heroku-johnny/buildpack-elixir" }
      ]
    }
  }
}
```

By default the buildpack runs `mix test`. Override with the `test_args` config variable:

```bash
# In ENV_VARS or app.json environment config
TEST_ARGS="--only integration"
```

The test environment sets `MIX_ENV=test` automatically.

## Caching

The buildpack caches Erlang, Elixir, and Mix dependencies between builds. The cache
is keyed by stack, OTP version, and Elixir version (including OTP major). Changing
any of these automatically invalidates the relevant cache layer.

Force a full cache clear on the next build:

```bash
# In elixir_buildpack.config
always_rebuild=true
```

Reset it to `false` after the build completes, or the cache will be cleared on every
subsequent deploy.

## Migrating from HashNuke's buildpack

If you're currently using [HashNuke/heroku-buildpack-elixir](https://github.com/HashNuke/heroku-buildpack-elixir),
migration is straightforward. The config file name and most options are identical.

### Quick migration

```bash
heroku buildpacks:set https://github.com/heroku-johnny/buildpack-elixir
git push heroku main
```

That's it for most apps. Read on if you hit any of the breaking changes below.

### Breaking changes

| Change | Action required |
|---|---|
| `erlang_version` and `elixir_version` are now **required** | Add both to your `elixir_buildpack.config` if missing |
| `pre_compile` and `post_compile` are removed | Rename to `hook_pre_compile` / `hook_post_compile` (they were already deprecated in the old buildpack) |
| `config_vars_to_export` is not supported | Remove it; config vars from `heroku config` are already available during build |

### Upgrading stacks at the same time

If you're also upgrading from heroku-22 or heroku-24 to heroku-26, update your OTP
and Elixir versions — heroku-26 requires OTP 26.0+ and Elixir 1.15+:

```bash
# elixir_buildpack.config
erlang_version=27.2
elixir_version=v1.18.3
```

Check available OTP versions for heroku-26:
https://builds.hex.pm/builds/otp/ubuntu-26.04/builds.txt

## Contributing

1. Fork the repository
2. Create a feature branch: `git checkout -b feat/your-change`
3. Make your changes
4. Run the test suite: `test/bats/bin/bats test/unit/`
5. Run the linter: `shellcheck bin/detect bin/compile bin/release bin/test bin/test-compile lib/*.sh`
6. Open a pull request with a conventional commit title (e.g. `feat: add support for X`)

### Running tests locally

The test suite uses [bats-core](https://github.com/bats-core/bats-core) (included as
a git submodule). Run tests for a specific stack:

```bash
STACK=heroku-22 test/bats/bin/bats test/unit/
STACK=heroku-24 test/bats/bin/bats test/unit/
STACK=heroku-26 test/bats/bin/bats test/unit/
```

## License

[MIT](LICENSE)
