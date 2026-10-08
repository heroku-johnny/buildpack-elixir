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

  local tmp_dir
  tmp_dir=$(mktemp -d)

  tar zxf "$(erlang_cache_dir)/$(otp_tarball_name)" -C "${tmp_dir}" --strip-components=1

  # OTP 24 and earlier hardcode ROOTDIR in the erl wrapper via Install.
  # Symlinking the runtime path to the temp dir lets Install verify the
  # directory exists while setting ROOTDIR to the runtime path (/app/...),
  # not the temp path. Same approach used by HashNuke's buildpack.
  rm -rf "$(erlang_runtime_dir)"
  mkdir -p "$(dirname "$(erlang_runtime_dir)")"
  ln -s "${tmp_dir}" "$(erlang_runtime_dir)"
  "${tmp_dir}/Install" -minimal "$(erlang_runtime_dir)"
  rm "$(erlang_runtime_dir)"

  mkdir -p "$(erlang_runtime_dir)"
  cp -R "${tmp_dir}/." "$(erlang_runtime_dir)/"
  rm -rf "${tmp_dir}"

  # On Heroku's older build system BUILD_DIR != /app, so also copy to the
  # build path so OTP is available during hex install, deps.get, and compile.
  if [ "$(erlang_build_dir)" != "$(erlang_runtime_dir)" ]; then
    mkdir -p "$(erlang_build_dir)"
    cp -R "$(erlang_runtime_dir)/." "$(erlang_build_dir)/"
  fi

  PATH="$(erlang_build_dir)/bin:${PATH}"
  export PATH
  output_line "OTP ${erlang_version} ready"
}
