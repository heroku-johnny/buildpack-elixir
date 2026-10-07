#!/usr/bin/env bats

load "../test_helper"

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

write_app_config() {
  cat > "${build_path}/elixir_buildpack.config" <<EOF
$1
EOF
}

# --- load_config ---

@test "load_config fails when app config is missing" {
  run load_config
  [ "$status" -eq 1 ]
  [[ "$output" == *"elixir_buildpack.config not found"* ]]
}

@test "load_config fails when erlang_version is missing" {
  write_app_config "elixir_version=1.18.3"
  run load_config
  [ "$status" -eq 1 ]
  [[ "$output" == *"erlang_version is not set"* ]]
}

@test "load_config fails when elixir_version is missing" {
  write_app_config "erlang_version=27.2"
  run load_config
  [ "$status" -eq 1 ]
  [[ "$output" == *"elixir_version is not set"* ]]
}

@test "load_config succeeds with valid erlang and elixir versions" {
  write_app_config $'erlang_version=27.2\nelixir_version=1.18.3'
  run load_config
  [ "$status" -eq 0 ]
}

@test "load_config outputs the stack, OTP, and Elixir versions" {
  write_app_config $'erlang_version=27.2\nelixir_version=1.18.3'
  run load_config
  [ "$status" -eq 0 ]
  [[ "$output" == *"heroku-22"* ]]
  [[ "$output" == *"27.2"* ]]
  [[ "$output" == *"v1.18.3"* ]]
}

# --- normalize_erlang_version ---

@test "normalize_erlang_version strips non-numeric characters" {
  erlang_version="OTP-27.2"
  normalize_erlang_version
  [ "$erlang_version" = "27.2" ]
}

@test "normalize_erlang_version leaves clean version unchanged" {
  erlang_version="27.2.1"
  normalize_erlang_version
  [ "$erlang_version" = "27.2.1" ]
}

# --- normalize_elixir_version ---

@test "normalize_elixir_version prefixes with v" {
  elixir_version="1.18.3"
  normalize_elixir_version
  [ "$elixir_version" = "v1.18.3" ]
}

@test "normalize_elixir_version with branch syntax sets elixir_branch" {
  elixir_version="branch main"
  normalize_elixir_version
  [ "$elixir_branch" = "main" ]
  [ "$elixir_force_fetch" = "true" ]
}

@test "normalize_elixir_version strips non-numeric prefix before v-prefixing" {
  elixir_version="v1.18.3"
  normalize_elixir_version
  [ "$elixir_version" = "v1.18.3" ]
}

# --- export_mix_env ---

@test "export_mix_env defaults to prod" {
  unset MIX_ENV
  export_mix_env
  [ "$MIX_ENV" = "prod" ]
}

@test "export_mix_env respects existing MIX_ENV" {
  export MIX_ENV="staging"
  export_mix_env
  [ "$MIX_ENV" = "staging" ]
}

@test "export_mix_env reads from env_dir file" {
  unset MIX_ENV
  echo "test" > "${env_path}/MIX_ENV"
  export_mix_env
  [ "$MIX_ENV" = "test" ]
}

@test "export_mix_env accepts default override argument" {
  unset MIX_ENV
  export_mix_env "test"
  [ "$MIX_ENV" = "test" ]
}
