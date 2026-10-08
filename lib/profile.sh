#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2154  # build_path, buildpack_path, MIX_ENV, MIX_HOME, HEX_HOME set by bin/compile

write_profile_d() {
  output_section "Writing runtime environment"

  mkdir -p "${build_path}/.profile.d"
  local profile="${build_path}/.profile.d/elixir-buildpack.sh"

  cat >"${profile}" <<PROFILE
export PATH="\${HOME}/.platform_tools/erlang/bin:\${HOME}/.platform_tools/elixir/bin:\${PATH}"
export LC_CTYPE="\${LC_CTYPE:-en_US.utf8}"
export MIX_ENV="\${MIX_ENV:-${MIX_ENV}}"
export MIX_HOME="\${MIX_HOME:-\${HOME}/.mix}"
export HEX_HOME="\${HEX_HOME:-\${HOME}/.hex}"
PROFILE

  chmod +x "${profile}"
}

write_export() {
  output_section "Writing export for multi-buildpack support"

  local export_file="${buildpack_path}/export"

  cat >"${export_file}" <<EXPORT
export PATH="$(erlang_build_dir)/bin:$(elixir_build_dir)/bin:\${PATH}"
export LC_CTYPE="\${LC_CTYPE:-en_US.utf8}"
export MIX_ENV="${MIX_ENV}"
export MIX_HOME="$(mix_build_dir)"
export HEX_HOME="$(hex_build_dir)"
EXPORT
}
