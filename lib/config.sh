#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2154  # buildpack_path, build_path, env_path set by bin/compile before sourcing

load_config() {
  output_section "Loading configuration"

  local buildpack_config="${buildpack_path}/elixir_buildpack.config"
  local app_config="${build_path}/elixir_buildpack.config"

  # shellcheck source=/dev/null
  source "${buildpack_config}"

  if [ ! -f "${app_config}" ]; then
    output_error "elixir_buildpack.config not found in your app."
    output_line "Create elixir_buildpack.config and set erlang_version and elixir_version."
    output_line "See: https://github.com/heroku-johnny/buildpack-elixir#configuration"
    exit 1
  fi

  # shellcheck source=/dev/null
  source "${app_config}"

  validate_config
}

validate_config() {
  if [ -z "${erlang_version}" ]; then
    output_error "erlang_version is not set in elixir_buildpack.config."
    output_line "Example: erlang_version=27.2"
    output_line "Available versions: https://builds.hex.pm/builds/otp/ubuntu-22.04/builds.txt"
    exit 1
  fi

  if [ -z "${elixir_version}" ] && [ -z "${elixir_branch}" ]; then
    output_error "elixir_version is not set in elixir_buildpack.config."
    output_line "Example: elixir_version=1.18.3"
    output_line "Available versions: https://builds.hex.pm/builds/elixir/builds.txt"
    exit 1
  fi

  normalize_erlang_version
  normalize_elixir_version
  validate_otp_for_stack "${erlang_version}"

  output_line "Stack:  ${STACK}"
  output_line "OTP:    ${erlang_version}"
  output_line "Elixir: ${elixir_version}"
  output_line "MIX_ENV: ${MIX_ENV}"
}

normalize_erlang_version() {
  # SC2001: [^0-9.] negation class is not expressible with bash ${//}
  # shellcheck disable=SC2001
  erlang_version=$(echo "${erlang_version}" | sed 's/[^0-9.]//g')
}

normalize_elixir_version() {
  # Support "branch <name>" syntax for prerelease tracking
  if [[ "${elixir_version}" =~ ^branch[[:space:]]+(.+)$ ]]; then
    elixir_branch="${BASH_REMATCH[1]}"
    elixir_version="${elixir_branch}"
    elixir_force_fetch=true
    return
  fi

  # shellcheck disable=SC2034  # elixir_force_fetch consumed by lib/elixir.sh
  elixir_force_fetch=false

  # SC2001: [^0-9.] negation class is not expressible with bash ${//}
  # shellcheck disable=SC2001
  elixir_version=$(echo "${elixir_version}" | sed 's/[^0-9.]//g')
  elixir_version="v${elixir_version}"
}

export_env_vars() {
  local env_dir="$1"
  local denylist='^(PATH|GIT_DIR|CPATH|CPPATH|LD_PRELOAD|LIBRARY_PATH)$'

  if [ -d "${env_dir}" ]; then
    output_section "Exporting config vars"
    for file in "${env_dir}"/*; do
      local key
      key=$(basename "${file}")
      if ! echo "${key}" | grep -qE "${denylist}"; then
        export "${key}=$(cat "${file}")"
        output_line "${key}"
      fi
    done
  fi
}

export_mix_env() {
  local default="${1:-prod}"

  if [ -z "${MIX_ENV}" ]; then
    if [ -f "${env_path}/MIX_ENV" ]; then
      local _val
      _val=$(cat "${env_path}/MIX_ENV")
      export MIX_ENV="${_val}"
    else
      export MIX_ENV="${default}"
    fi
  fi
}

export_mix_home() {
  if [ -z "${MIX_HOME}" ]; then
    local _val
    if [ -f "${env_path}/MIX_HOME" ]; then
      _val=$(cat "${env_path}/MIX_HOME")
    else
      _val=$(mix_build_dir)
    fi
    export MIX_HOME="${_val}"
  fi
}

export_hex_home() {
  if [ -z "${HEX_HOME}" ]; then
    local _val
    if [ -f "${env_path}/HEX_HOME" ]; then
      _val=$(cat "${env_path}/HEX_HOME")
    else
      _val=$(hex_build_dir)
    fi
    export HEX_HOME="${_val}"
  fi
}
