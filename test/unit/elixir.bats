#!/usr/bin/env bats

load "../test_helper"

setup() {
  setup_test_dirs
  export STACK="heroku-22"
  export erlang_version="27.2"
  export elixir_version="v1.18.3"
  export elixir_force_fetch=false
  buildpack_path="${BUILDPACK_ROOT}"
  source "${BUILDPACK_ROOT}/lib/output.sh"
  source "${BUILDPACK_ROOT}/lib/paths.sh"
  source "${BUILDPACK_ROOT}/lib/stack.sh"
  source "${BUILDPACK_ROOT}/lib/elixir.sh"
}

teardown() {
  teardown_test_dirs
}

# --- otp_major ---

@test "otp_major extracts major from full version" {
  erlang_version="27.3.1"
  [ "$(otp_major)" = "27" ]
}

@test "otp_major extracts major from minor-only version" {
  erlang_version="27.2"
  [ "$(otp_major)" = "27" ]
}

@test "otp_major handles double-digit major" {
  erlang_version="29.1.1"
  [ "$(otp_major)" = "29" ]
}

@test "otp_major handles single-dot version" {
  erlang_version="26.0"
  [ "$(otp_major)" = "26" ]
}

# --- elixir_zip_name ---

@test "elixir_zip_name includes elixir version and OTP major" {
  result=$(elixir_zip_name)
  [[ "$result" == *"v1.18.3"* ]]
  [[ "$result" == *"otp-27"* ]]
}

@test "elixir_zip_name uses .zip extension" {
  [[ "$(elixir_zip_name)" == *.zip ]]
}

@test "elixir_zip_name changes when OTP major changes" {
  erlang_version="27.2"
  name_27=$(elixir_zip_name)
  erlang_version="26.2"
  name_26=$(elixir_zip_name)
  [ "$name_27" != "$name_26" ]
}

# --- elixir_otp_specific_url ---

@test "elixir_otp_specific_url includes version and OTP major" {
  url=$(elixir_otp_specific_url)
  [[ "$url" == *"v1.18.3-otp-27"* ]]
}

@test "elixir_otp_specific_url uses builds.hex.pm" {
  [[ "$(elixir_otp_specific_url)" == *"builds.hex.pm"* ]]
}

# --- elixir_generic_url ---

@test "elixir_generic_url includes version without OTP suffix" {
  url=$(elixir_generic_url)
  [[ "$url" == *"v1.18.3.zip"* ]]
  [[ "$url" != *"otp"* ]]
}

# --- elixir_version_cached ---

@test "elixir_version_cached returns false when cache is empty" {
  run elixir_version_cached
  [ "$status" -ne 0 ]
}

@test "elixir_version_cached returns false when marker has different version" {
  mkdir -p "$(elixir_cache_dir)"
  echo "v1.17.0-otp-27" > "$(elixir_cache_dir)/.version"
  run elixir_version_cached
  [ "$status" -ne 0 ]
}

@test "elixir_version_cached returns true when marker matches version and OTP major" {
  mkdir -p "$(elixir_cache_dir)"
  echo "v1.18.3-otp-27" > "$(elixir_cache_dir)/.version"
  run elixir_version_cached
  [ "$status" -eq 0 ]
}

@test "elixir_version_cached returns false when OTP major changes" {
  mkdir -p "$(elixir_cache_dir)"
  echo "v1.18.3-otp-27" > "$(elixir_cache_dir)/.version"
  erlang_version="26.2"
  run elixir_version_cached
  [ "$status" -ne 0 ]
}

# --- _mark_elixir_cached ---

@test "_mark_elixir_cached writes version and OTP major to marker" {
  mkdir -p "$(elixir_cache_dir)"
  _mark_elixir_cached
  [ "$(cat "$(elixir_cache_dir)/.version")" = "v1.18.3-otp-27" ]
}

@test "elixir_version_cached returns true after _mark_elixir_cached" {
  mkdir -p "$(elixir_cache_dir)"
  _mark_elixir_cached
  elixir_version_cached
}

@test "_mark_elixir_cached marker reflects OTP major not full version" {
  erlang_version="27.3.4"
  mkdir -p "$(elixir_cache_dir)"
  _mark_elixir_cached
  marker=$(cat "$(elixir_cache_dir)/.version")
  [[ "$marker" == *"otp-27"* ]]
  [[ "$marker" != *"otp-27.3"* ]]
}
