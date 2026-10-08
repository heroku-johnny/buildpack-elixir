#!/usr/bin/env bats

load "../test_helper"

setup() {
  setup_test_dirs
  export STACK="heroku-22"
  export MIX_ENV="prod"
  buildpack_path="${BUILDPACK_ROOT}"
  source "${BUILDPACK_ROOT}/lib/output.sh"
  source "${BUILDPACK_ROOT}/lib/paths.sh"
  source "${BUILDPACK_ROOT}/lib/stack.sh"
  source "${BUILDPACK_ROOT}/lib/hooks.sh"
}

teardown() {
  teardown_test_dirs
}

# --- run_hook ---

@test "run_hook does nothing when command is empty" {
  run run_hook "hook_pre_compile" ""
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "run_hook executes the command" {
  local marker="${TEST_TMPDIR}/hook_ran"
  run run_hook "hook_pre_compile" "touch ${marker}"
  [ "$status" -eq 0 ]
  [ -f "${marker}" ]
}

@test "run_hook runs in build_path directory" {
  local result_file="${TEST_TMPDIR}/cwd.txt"
  run run_hook "hook_pre_compile" "pwd > ${result_file}"
  [ "$status" -eq 0 ]
  [ "$(cat "${result_file}")" = "${build_path}" ]
}

@test "run_hook exits 1 and shows error when command fails" {
  run run_hook "hook_pre_compile" "exit 1"
  [ "$status" -eq 1 ]
  [[ "$output" == *"Hook 'hook_pre_compile' failed"* ]]
}

@test "run_hook shows the failed command in the error message" {
  run run_hook "hook_post_compile" "exit 42"
  [ "$status" -eq 1 ]
  [[ "$output" == *"exit 42"* ]]
}

# --- named hook functions ---

@test "hook_pre_fetch_dependencies does nothing when unset" {
  hook_pre_fetch_dependencies=""
  run hook_pre_fetch_dependencies
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "hook_pre_fetch_dependencies runs when set" {
  local marker="${TEST_TMPDIR}/pre_fetch_ran"
  hook_pre_fetch_dependencies="touch ${marker}"
  hook_pre_fetch_dependencies
  [ -f "${marker}" ]
}

@test "hook_pre_compile does nothing when unset" {
  hook_pre_compile=""
  run hook_pre_compile
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "hook_pre_compile runs when set" {
  local marker="${TEST_TMPDIR}/pre_compile_ran"
  hook_pre_compile="touch ${marker}"
  hook_pre_compile
  [ -f "${marker}" ]
}

@test "hook_post_compile does nothing when unset" {
  hook_post_compile=""
  run hook_post_compile
  [ "$status" -eq 0 ]
  [ -z "$output" ]
}

@test "hook_post_compile exits 1 when command fails" {
  hook_post_compile="exit 1"
  run hook_post_compile
  [ "$status" -eq 1 ]
}
