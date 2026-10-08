#!/usr/bin/env bats

load "../test_helper"

FIXTURES_DIR="$(cd "$(dirname "${BATS_TEST_FILENAME}")/../fixtures" && pwd)"

setup() {
  setup_test_dirs
  export STACK="heroku-22"
  buildpack_path="${BUILDPACK_ROOT}"
  source "${BUILDPACK_ROOT}/lib/output.sh"
  source "${BUILDPACK_ROOT}/lib/paths.sh"
  source "${BUILDPACK_ROOT}/lib/stack.sh"
  source "${BUILDPACK_ROOT}/lib/config.sh"
}

teardown() {
  teardown_test_dirs
}

use_fixture() {
  cp "${FIXTURES_DIR}/${1}/elixir_buildpack.config" "${build_path}/elixir_buildpack.config"
}

# --- phoenix-app ---

@test "phoenix-app fixture loads without error" {
  use_fixture phoenix-app
  run load_config
  [ "$status" -eq 0 ]
}

@test "phoenix-app fixture sets erlang_version" {
  use_fixture phoenix-app
  load_config
  [ -n "${erlang_version}" ]
}

@test "phoenix-app fixture sets elixir_version" {
  use_fixture phoenix-app
  load_config
  [ -n "${elixir_version}" ]
}

@test "phoenix-app fixture enables release" {
  use_fixture phoenix-app
  load_config
  [ "${release}" = "true" ]
}

@test "phoenix-app fixture sets hook_pre_compile" {
  use_fixture phoenix-app
  load_config
  [ -n "${hook_pre_compile}" ]
}

# --- umbrella-app ---

@test "umbrella-app fixture loads without error" {
  use_fixture umbrella-app
  run load_config
  [ "$status" -eq 0 ]
}

@test "umbrella-app fixture sets erlang_version" {
  use_fixture umbrella-app
  load_config
  [ -n "${erlang_version}" ]
}

@test "umbrella-app fixture sets elixir_version" {
  use_fixture umbrella-app
  load_config
  [ -n "${elixir_version}" ]
}

@test "umbrella-app fixture has release disabled by default" {
  use_fixture umbrella-app
  load_config
  [ "${release}" = "false" ]
}
