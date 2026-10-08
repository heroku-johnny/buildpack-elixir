#!/usr/bin/env bash

# Detect whether the Heroku stack has changed since the last build.
# Returns 0 if changed, 1 if unchanged or first build.
stack_changed() {
  local marker
  marker="$(stack_marker_file)"
  [ -f "${marker}" ] && [ "$(cat "${marker}")" != "${STACK}" ]
}

_mark_stack_cached() {
  mkdir -p "$(dirname "$(stack_marker_file)")"
  echo "${STACK}" > "$(stack_marker_file)"
}

# Wipe the entire stack-namespaced cache. Called on stack change or always_rebuild.
clear_stack_cache() {
  rm -rf "$(stack_cache_dir)"
}

# Called at the start of bin/compile to handle cache invalidation triggers.
prepare_cache() {
  if [ "${always_rebuild}" = "true" ]; then
    output_section "Clearing cache (always_rebuild=true)"
    clear_stack_cache
  elif stack_changed; then
    output_section "Stack changed to ${STACK}, clearing cache"
    clear_stack_cache
  fi

  mkdir -p "$(stack_cache_dir)"
  _mark_stack_cached
}

# --- App dependency cache (deps/ and _build/) ---

restore_app_cache() {
  if [ -d "$(deps_backup_dir)" ]; then
    mkdir -p "${build_path}/deps"
    cp -pR "$(deps_backup_dir)/." "${build_path}/deps/"
  fi

  if [ -d "$(build_backup_dir)" ]; then
    mkdir -p "${build_path}/_build"
    cp -pR "$(build_backup_dir)/." "${build_path}/_build/"
  fi
}

backup_app_cache() {
  rm -rf "$(deps_backup_dir)" "$(build_backup_dir)"

  if [ -d "${build_path}/deps" ]; then
    mkdir -p "$(deps_backup_dir)"
    cp -pR "${build_path}/deps/." "$(deps_backup_dir)/"
  fi

  if [ -d "${build_path}/_build" ]; then
    mkdir -p "$(build_backup_dir)"
    cp -pR "${build_path}/_build/." "$(build_backup_dir)/"
  fi
}

# --- Mix/Hex home cache (.mix/ and .hex/) ---

restore_mix_cache() {
  if [ -d "$(mix_backup_dir)" ]; then
    mkdir -p "$(mix_build_dir)"
    cp -pR "$(mix_backup_dir)/." "$(mix_build_dir)/"
  fi

  if [ -d "$(hex_backup_dir)" ]; then
    mkdir -p "$(hex_build_dir)"
    cp -pR "$(hex_backup_dir)/." "$(hex_build_dir)/"
  fi
}

backup_mix_cache() {
  rm -rf "$(mix_backup_dir)" "$(hex_backup_dir)"

  if [ -d "$(mix_build_dir)" ]; then
    mkdir -p "$(mix_backup_dir)"
    cp -pR "$(mix_build_dir)/." "$(mix_backup_dir)/"
  fi

  if [ -d "$(hex_build_dir)" ]; then
    mkdir -p "$(hex_backup_dir)"
    cp -pR "$(hex_build_dir)/." "$(hex_backup_dir)/"
  fi
}
