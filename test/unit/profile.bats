#!/usr/bin/env bats

load "../test_helper"

setup() {
  setup_test_dirs
  export STACK="heroku-22"
  export MIX_ENV="prod"
  export erlang_version="27.2"
  export elixir_version="v1.18.3"
  buildpack_path="${BUILDPACK_ROOT}"
  source "${BUILDPACK_ROOT}/lib/output.sh"
  source "${BUILDPACK_ROOT}/lib/paths.sh"
  source "${BUILDPACK_ROOT}/lib/stack.sh"
  source "${BUILDPACK_ROOT}/lib/profile.sh"

  # write_export writes to buildpack_path/export — redirect to tmp
  buildpack_path="${TEST_TMPDIR}"
}

teardown() {
  teardown_test_dirs
}

profile_file() {
  echo "${build_path}/.profile.d/elixir-buildpack.sh"
}

# --- write_profile_d ---

@test "write_profile_d creates .profile.d directory" {
  write_profile_d
  [ -d "${build_path}/.profile.d" ]
}

@test "write_profile_d creates the profile script" {
  write_profile_d
  [ -f "$(profile_file)" ]
}

@test "write_profile_d script is executable" {
  write_profile_d
  [ -x "$(profile_file)" ]
}

@test "write_profile_d script sets PATH with erlang and elixir bin dirs" {
  write_profile_d
  local content
  content=$(cat "$(profile_file)")
  [[ "$content" == *"erlang/bin"* ]]
  [[ "$content" == *"elixir/bin"* ]]
}

@test "write_profile_d script sets MIX_ENV with current value as default" {
  MIX_ENV="staging"
  write_profile_d
  local content
  content=$(cat "$(profile_file)")
  [[ "$content" == *"staging"* ]]
}

@test "write_profile_d script uses parameter substitution for PATH" {
  write_profile_d
  local content
  content=$(cat "$(profile_file)")
  [[ "$content" == *'${PATH}'* ]]
}

@test "write_profile_d script sets LC_CTYPE with fallback" {
  write_profile_d
  local content
  content=$(cat "$(profile_file)")
  [[ "$content" == *"LC_CTYPE"* ]]
}

# --- write_export ---

@test "write_export creates export file in buildpack_path" {
  write_export
  [ -f "${buildpack_path}/export" ]
}

@test "write_export includes erlang and elixir bin paths" {
  write_export
  local content
  content=$(cat "${buildpack_path}/export")
  [[ "$content" == *"erlang"* ]]
  [[ "$content" == *"elixir"* ]]
}

@test "write_export sets MIX_HOME and HEX_HOME" {
  write_export
  local content
  content=$(cat "${buildpack_path}/export")
  [[ "$content" == *"MIX_HOME"* ]]
  [[ "$content" == *"HEX_HOME"* ]]
}
