#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2154  # erlang_version, STACK set by bin/compile before sourcing

otp_tarball_name() {
  echo "OTP-${erlang_version}.tar.gz"
}

otp_download_url() {
  echo "$(otp_base_url)/$(otp_tarball_name)"
}

# Returns 0 if the cached OTP version matches the requested version.
erlang_version_cached() {
  local marker
  marker="$(erlang_cache_dir)/.version"
  [ -f "${marker}" ] && [ "$(cat "${marker}")" = "${erlang_version}" ]
}

_mark_erlang_cached() {
  echo "${erlang_version}" >"$(erlang_cache_dir)/.version"
}

download_erlang() {
  mkdir -p "$(erlang_cache_dir)"

  if erlang_version_cached; then
    output_section "Using cached OTP ${erlang_version}"
    return
  fi

  local url
  url=$(otp_download_url)

  output_section "Downloading OTP ${erlang_version}"
  output_line "Source: ${url}"

  rm -rf "$(erlang_cache_dir)"
  mkdir -p "$(erlang_cache_dir)"

  if ! curl --fail --silent --show-error --location \
    --output "$(erlang_cache_dir)/$(otp_tarball_name)" \
    "${url}"; then
    output_error "Could not download OTP ${erlang_version} for ${STACK}."
    output_line "Check erlang_version in elixir_buildpack.config."
    output_line "Available versions: $(otp_base_url)/builds.txt"
    exit 1
  fi

  _mark_erlang_cached
}

install_erlang() {
  output_section "Installing OTP ${erlang_version}"

  # Extract directly to the final location so OTP's Install script sets
  # ROOTDIR correctly. Extracting to a temp dir and copying causes OTP 24's
  # erl wrapper to have the wrong (now-deleted) ROOTDIR.
  rm -rf "$(erlang_build_dir)"
  mkdir -p "$(erlang_build_dir)"

  tar zxf "$(erlang_cache_dir)/$(otp_tarball_name)" -C "$(erlang_build_dir)" --strip-components=1
  "$(erlang_build_dir)/Install" -minimal "$(erlang_build_dir)"

  PATH="$(erlang_build_dir)/bin:${PATH}"
  export PATH
  output_line "OTP ${erlang_version} ready"
}
