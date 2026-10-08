#!/usr/bin/env bats

load "../test_helper"

setup() {
  setup_test_dirs
  export STACK="heroku-22"
  export MIX_ENV="prod"
  export release=false
  export hook_compile=""
  buildpack_path="${BUILDPACK_ROOT}"
  source "${BUILDPACK_ROOT}/lib/output.sh"
  source "${BUILDPACK_ROOT}/lib/paths.sh"
  source "${BUILDPACK_ROOT}/lib/stack.sh"
  source "${BUILDPACK_ROOT}/lib/app.sh"
}

teardown() {
  teardown_test_dirs
}

# --- build_release ---

@test "build_release does nothing when release=false" {
  release=false
  run build_release
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "build_release outputs section header when release=true" {
  release=true
  # mix release will fail in test (no mix project) but we check the output up to that point
  run build_release
  [[ "$output" == *"Building release"* ]]
}

@test "build_release exits 1 when mix release fails" {
  release=true
  run build_release
  [ "$status" -eq 1 ]
}

@test "build_release error message mentions mix.exs" {
  release=true
  run build_release
  [[ "$output" == *"mix.exs"* ]]
}

# --- compile_app ---

@test "compile_app uses custom hook_compile when set" {
  hook_compile="echo 'custom compile ran'"
  run compile_app
  [ "$status" -eq 0 ]
  [[ "$output" == *"custom compile ran"* ]]
}

@test "compile_app shows custom compile command in output" {
  hook_compile="echo 'custom compile ran'"
  run compile_app
  [[ "$output" == *"custom compile"* ]]
}

@test "compile_app exits 1 when custom hook_compile fails" {
  hook_compile="exit 1"
  run compile_app
  [ "$status" -eq 1 ]
}
