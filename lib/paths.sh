#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2154  # build_path, cache_path, runtime_path, STACK set by bin/compile

# Build-time paths (under BUILD_DIR / CACHE_DIR)

platform_tools_dir() {
  echo "${build_path}/.platform_tools"
}

erlang_build_dir() {
  echo "$(platform_tools_dir)/erlang"
}

elixir_build_dir() {
  echo "$(platform_tools_dir)/elixir"
}

mix_build_dir() {
  echo "${build_path}/.mix"
}

hex_build_dir() {
  echo "${build_path}/.hex"
}

# Runtime paths (under runtime_path, typically /app)

erlang_runtime_dir() {
  echo "${runtime_path}/.platform_tools/erlang"
}

elixir_runtime_dir() {
  echo "${runtime_path}/.platform_tools/elixir"
}

mix_runtime_dir() {
  echo "${runtime_path}/.mix"
}

hex_runtime_dir() {
  echo "${runtime_path}/.hex"
}

# Cache paths (stack-namespaced to isolate across stack changes)

stack_cache_dir() {
  echo "${cache_path}/buildpack-elixir/${STACK}"
}

erlang_cache_dir() {
  echo "$(stack_cache_dir)/erlang"
}

elixir_cache_dir() {
  echo "$(stack_cache_dir)/elixir"
}

deps_backup_dir() {
  echo "$(stack_cache_dir)/deps"
}

build_backup_dir() {
  echo "$(stack_cache_dir)/build"
}

mix_backup_dir() {
  echo "$(stack_cache_dir)/.mix"
}

hex_backup_dir() {
  echo "$(stack_cache_dir)/.hex"
}

stack_marker_file() {
  echo "${cache_path}/buildpack-elixir/stack"
}
