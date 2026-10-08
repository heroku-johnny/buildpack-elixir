#!/usr/bin/env bash

# Extract the major version number from an OTP version string.
# e.g. 27.3.1 → 27
otp_major() {
  echo "${erlang_version}" | cut -d. -f1
}

elixir_zip_name() {
  echo "elixir-${elixir_version}-otp-$(otp_major).zip"
}

elixir_otp_specific_url() {
  echo "https://builds.hex.pm/builds/elixir/${elixir_version}-otp-$(otp_major).zip"
}

elixir_generic_url() {
  echo "https://builds.hex.pm/builds/elixir/${elixir_version}.zip"
}

# Returns 0 if the cached Elixir version matches the requested version + OTP major.
# Including the OTP major ensures that an OTP upgrade invalidates the Elixir cache.
elixir_version_cached() {
  local marker
  marker="$(elixir_cache_dir)/.version"
  [ -f "${marker}" ] && [ "$(cat "${marker}")" = "${elixir_version}-otp-$(otp_major)" ]
}

_mark_elixir_cached() {
  echo "${elixir_version}-otp-$(otp_major)" > "$(elixir_cache_dir)/.version"
}

download_elixir() {
  mkdir -p "$(elixir_cache_dir)"

  if [ "${elixir_force_fetch}" != "true" ] && elixir_version_cached; then
    output_section "Using cached Elixir ${elixir_version}"
    return
  fi

  rm -rf "$(elixir_cache_dir)"
  mkdir -p "$(elixir_cache_dir)"

  local zip_path
  zip_path="$(elixir_cache_dir)/$(elixir_zip_name)"

  local otp_url
  otp_url=$(elixir_otp_specific_url)

  output_section "Downloading Elixir ${elixir_version} (OTP $(otp_major))"
  output_line "Source: ${otp_url}"

  if curl --fail --silent --show-error --location \
       --output "${zip_path}" "${otp_url}" 2>/dev/null; then
    _mark_elixir_cached
    return
  fi

  # OTP-specific build unavailable — fall back to the generic build.
  local generic_url
  generic_url=$(elixir_generic_url)

  output_line "OTP-specific build unavailable, trying generic build"
  output_line "Source: ${generic_url}"

  if curl --fail --silent --show-error --location \
       --output "${zip_path}" "${generic_url}" 2>/dev/null; then
    _mark_elixir_cached
    return
  fi

  output_error "Could not download Elixir ${elixir_version}."
  output_line  "Check elixir_version in elixir_buildpack.config."
  output_line  "Available versions: https://builds.hex.pm/builds/elixir/builds.txt"
  exit 1
}

install_elixir() {
  output_section "Installing Elixir ${elixir_version}"

  rm -rf "$(elixir_build_dir)"
  mkdir -p "$(elixir_build_dir)"

  local zip_path
  zip_path="$(elixir_cache_dir)/$(elixir_zip_name)"

  if command -v unzip &>/dev/null; then
    unzip -q "${zip_path}" -d "$(elixir_build_dir)"
  else
    (cd "$(elixir_build_dir)" && jar xf "${zip_path}")
  fi

  chmod +x "$(elixir_build_dir)/bin/"*
  export PATH="$(elixir_build_dir)/bin:${PATH}"
  export LC_CTYPE="${LC_CTYPE:-en_US.utf8}"

  output_line "Elixir ${elixir_version} ready"
}
