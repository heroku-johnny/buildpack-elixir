## Summary

<!-- What changed and why. Link to an issue if applicable. -->

## Test plan

- [ ] CI passes (shellcheck, shfmt, unit tests)
- [ ] Unit tests pass locally: `STACK=heroku-22 test/bats/bin/bats test/unit/`
- [ ] If `bin/` or `lib/` changed: smoke tested `bin/detect` and `bin/compile` against a local app directory

## Breaking changes

<!-- List any breaking changes to elixir_buildpack.config options or the hook API. Write "None" if not applicable. -->
