#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2154  # build_path, MIX_ENV, hook_compile, release set by bin/compile

fetch_dependencies() {
  output_section "Fetching dependencies"
  (
    cd "${build_path}"
    unset GIT_DIR
    mix deps.get --only "${MIX_ENV}"
  ) || {
    output_error "mix deps.get failed."
    output_line "Check your mix.exs dependencies and network connectivity."
    exit 1
  }
}

compile_app() {
  output_section "Compiling"

  if [ -n "${hook_compile}" ]; then
    output_line "Using custom compile command: ${hook_compile}"
    (cd "${build_path}" && unset GIT_DIR && eval "${hook_compile}") || {
      output_error "Custom compile command failed (exit $?)."
      exit 1
    }
  else
    (cd "${build_path}" && unset GIT_DIR && mix compile) || {
      output_error "mix compile failed."
      exit 1
    }
  fi

  (cd "${build_path}" && mix deps.clean --unused --unlock 2>/dev/null || true)
}

build_release() {
  if [ "${release}" = "true" ]; then
    output_section "Building release"
    (cd "${build_path}" && unset GIT_DIR && mix release --overwrite) || {
      output_error "mix release failed."
      output_line "Ensure your mix.exs defines a release configuration."
      exit 1
    }
  fi
}
