#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2154  # hook_* vars, build_path set by bin/compile before sourcing

run_hook() {
  local name="$1"
  local cmd="$2"

  if [ -n "${cmd}" ]; then
    output_section "Running hook: ${name}"
    output_line "Command: ${cmd}"
    (cd "${build_path}" && unset GIT_DIR && eval "${cmd}") || {
      output_error "Hook '${name}' failed (exit $?)."
      output_line "Command: ${cmd}"
      exit 1
    }
  fi
}

hook_pre_fetch_dependencies() {
  run_hook "hook_pre_fetch_dependencies" "${hook_pre_fetch_dependencies}"
}

hook_pre_compile() {
  run_hook "hook_pre_compile" "${hook_pre_compile}"
}

hook_post_compile() {
  run_hook "hook_post_compile" "${hook_post_compile}"
}
