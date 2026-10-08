#!/usr/bin/env bats

load "../test_helper"

setup() {
  setup_test_dirs
  export STACK="heroku-22"
  export always_rebuild=false
  export erlang_version="27.2"
  export elixir_version="v1.18.3"
  buildpack_path="${BUILDPACK_ROOT}"
  source "${BUILDPACK_ROOT}/lib/output.sh"
  source "${BUILDPACK_ROOT}/lib/paths.sh"
  source "${BUILDPACK_ROOT}/lib/stack.sh"
  source "${BUILDPACK_ROOT}/lib/cache.sh"
}

teardown() {
  teardown_test_dirs
}

# --- stack_changed ---

@test "stack_changed returns false when no marker exists" {
  run stack_changed
  [ "$status" -ne 0 ]
}

@test "stack_changed returns false when marker matches current stack" {
  mkdir -p "$(dirname "$(stack_marker_file)")"
  echo "heroku-22" > "$(stack_marker_file)"
  run stack_changed
  [ "$status" -ne 0 ]
}

@test "stack_changed returns true when marker has a different stack" {
  mkdir -p "$(dirname "$(stack_marker_file)")"
  echo "heroku-24" > "$(stack_marker_file)"
  run stack_changed
  [ "$status" -eq 0 ]
}

# --- _mark_stack_cached ---

@test "_mark_stack_cached writes current stack to marker file" {
  _mark_stack_cached
  [ "$(cat "$(stack_marker_file)")" = "heroku-22" ]
}

@test "stack_changed returns false after _mark_stack_cached" {
  _mark_stack_cached
  run stack_changed
  [ "$status" -ne 0 ]
}

# --- clear_stack_cache ---

@test "clear_stack_cache removes the stack-namespaced cache directory" {
  mkdir -p "$(stack_cache_dir)/erlang"
  touch "$(stack_cache_dir)/erlang/some-file"
  clear_stack_cache
  [ ! -d "$(stack_cache_dir)" ]
}

@test "clear_stack_cache does not fail when cache dir does not exist" {
  run clear_stack_cache
  [ "$status" -eq 0 ]
}

# --- prepare_cache ---

@test "prepare_cache creates stack_cache_dir" {
  prepare_cache
  [ -d "$(stack_cache_dir)" ]
}

@test "prepare_cache writes stack marker" {
  prepare_cache
  [ "$(cat "$(stack_marker_file)")" = "heroku-22" ]
}

@test "prepare_cache clears cache when always_rebuild is true" {
  mkdir -p "$(stack_cache_dir)/erlang"
  touch "$(stack_cache_dir)/erlang/cached-file"
  always_rebuild=true
  prepare_cache
  [ ! -f "$(stack_cache_dir)/erlang/cached-file" ]
}

@test "prepare_cache clears cache on stack change" {
  mkdir -p "$(stack_cache_dir)/erlang"
  mkdir -p "$(dirname "$(stack_marker_file)")"
  echo "heroku-24" > "$(stack_marker_file)"
  prepare_cache
  [ ! -d "$(stack_cache_dir)/erlang" ]
}

@test "prepare_cache keeps cache when stack unchanged and always_rebuild is false" {
  prepare_cache
  mkdir -p "$(stack_cache_dir)/erlang"
  touch "$(stack_cache_dir)/erlang/cached-file"
  prepare_cache
  [ -f "$(stack_cache_dir)/erlang/cached-file" ]
}

# --- restore_app_cache ---

@test "restore_app_cache copies deps backup to build path" {
  mkdir -p "$(deps_backup_dir)"
  touch "$(deps_backup_dir)/my_dep"
  restore_app_cache
  [ -f "${build_path}/deps/my_dep" ]
}

@test "restore_app_cache copies build backup to build path" {
  mkdir -p "$(build_backup_dir)"
  touch "$(build_backup_dir)/compiled_artifact"
  restore_app_cache
  [ -f "${build_path}/_build/compiled_artifact" ]
}

@test "restore_app_cache does not fail when backups are absent" {
  run restore_app_cache
  [ "$status" -eq 0 ]
}

# --- backup_app_cache ---

@test "backup_app_cache copies deps to backup dir" {
  mkdir -p "${build_path}/deps"
  touch "${build_path}/deps/my_dep"
  backup_app_cache
  [ -f "$(deps_backup_dir)/my_dep" ]
}

@test "backup_app_cache copies _build to backup dir" {
  mkdir -p "${build_path}/_build"
  touch "${build_path}/_build/compiled_artifact"
  backup_app_cache
  [ -f "$(build_backup_dir)/compiled_artifact" ]
}

@test "backup_app_cache replaces existing backup" {
  mkdir -p "$(deps_backup_dir)"
  touch "$(deps_backup_dir)/old_dep"
  mkdir -p "${build_path}/deps"
  touch "${build_path}/deps/new_dep"
  backup_app_cache
  [ ! -f "$(deps_backup_dir)/old_dep" ]
  [ -f "$(deps_backup_dir)/new_dep" ]
}

@test "backup_app_cache does not fail when deps and _build are absent" {
  run backup_app_cache
  [ "$status" -eq 0 ]
}

# --- restore_mix_cache / backup_mix_cache ---

@test "restore_mix_cache copies mix backup to mix build dir" {
  mkdir -p "$(mix_backup_dir)"
  touch "$(mix_backup_dir)/hex_registry"
  restore_mix_cache
  [ -f "$(mix_build_dir)/hex_registry" ]
}

@test "backup_mix_cache copies mix build dir to backup" {
  mkdir -p "$(mix_build_dir)"
  touch "$(mix_build_dir)/hex_registry"
  backup_mix_cache
  [ -f "$(mix_backup_dir)/hex_registry" ]
}

@test "restore_mix_cache and backup_mix_cache round-trip preserves content" {
  mkdir -p "$(mix_build_dir)"
  echo "content" > "$(mix_build_dir)/hex_registry"
  backup_mix_cache
  rm -rf "$(mix_build_dir)"
  restore_mix_cache
  [ "$(cat "$(mix_build_dir)/hex_registry")" = "content" ]
}
