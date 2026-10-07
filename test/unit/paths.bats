#!/usr/bin/env bats

load "../test_helper"

setup() {
  setup_test_dirs
  export STACK="heroku-22"
  source "${BUILDPACK_ROOT}/lib/output.sh"
  source "${BUILDPACK_ROOT}/lib/paths.sh"
}

teardown() {
  teardown_test_dirs
}

@test "platform_tools_dir is under build_path" {
  result=$(platform_tools_dir)
  [[ "$result" == "${build_path}/.platform_tools" ]]
}

@test "erlang_build_dir is under platform_tools_dir" {
  result=$(erlang_build_dir)
  [[ "$result" == "$(platform_tools_dir)/erlang" ]]
}

@test "elixir_build_dir is under platform_tools_dir" {
  result=$(elixir_build_dir)
  [[ "$result" == "$(platform_tools_dir)/elixir" ]]
}

@test "erlang_runtime_dir uses runtime_path" {
  result=$(erlang_runtime_dir)
  [[ "$result" == "${runtime_path}/.platform_tools/erlang" ]]
}

@test "elixir_runtime_dir uses runtime_path" {
  result=$(elixir_runtime_dir)
  [[ "$result" == "${runtime_path}/.platform_tools/elixir" ]]
}

@test "stack_cache_dir includes STACK name" {
  result=$(stack_cache_dir)
  [[ "$result" == *"${STACK}"* ]]
  [[ "$result" == *"buildpack-elixir"* ]]
}

@test "stack_cache_dir differs across stacks" {
  STACK="heroku-22" result22=$(stack_cache_dir)
  STACK="heroku-26" result26=$(stack_cache_dir)
  [ "$result22" != "$result26" ]
}

@test "erlang_cache_dir is under stack_cache_dir" {
  result=$(erlang_cache_dir)
  [[ "$result" == "$(stack_cache_dir)/erlang" ]]
}

@test "deps_backup_dir is under stack_cache_dir" {
  result=$(deps_backup_dir)
  [[ "$result" == "$(stack_cache_dir)/deps" ]]
}
