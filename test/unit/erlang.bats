#!/usr/bin/env bats

load "../test_helper"

setup() {
  setup_test_dirs
  export STACK="heroku-22"
  export erlang_version="27.2"
  buildpack_path="${BUILDPACK_ROOT}"
  source "${BUILDPACK_ROOT}/lib/output.sh"
  source "${BUILDPACK_ROOT}/lib/paths.sh"
  source "${BUILDPACK_ROOT}/lib/stack.sh"
  source "${BUILDPACK_ROOT}/lib/erlang.sh"
}

teardown() {
  teardown_test_dirs
}

# --- otp_tarball_name ---

@test "otp_tarball_name includes the version" {
  [ "$(otp_tarball_name)" = "OTP-27.2.tar.gz" ]
}

@test "otp_tarball_name uses OTP- prefix" {
  [[ "$(otp_tarball_name)" == OTP-* ]]
}

@test "otp_tarball_name ends with .tar.gz" {
  [[ "$(otp_tarball_name)" == *.tar.gz ]]
}

# --- otp_download_url ---

@test "otp_download_url for heroku-22 uses ubuntu-22.04" {
  STACK="heroku-22"
  [[ "$(otp_download_url)" == *"ubuntu-22.04"* ]]
}

@test "otp_download_url for heroku-24 uses ubuntu-24.04" {
  STACK="heroku-24"
  [[ "$(otp_download_url)" == *"ubuntu-24.04"* ]]
}

@test "otp_download_url for heroku-26 uses ubuntu-26.04" {
  STACK="heroku-26"
  erlang_version="26.2"
  [[ "$(otp_download_url)" == *"ubuntu-26.04"* ]]
}

@test "otp_download_url includes tarball name" {
  url=$(otp_download_url)
  [[ "$url" == *"$(otp_tarball_name)"* ]]
}

# --- erlang_version_cached ---

@test "erlang_version_cached returns false when cache dir is empty" {
  run erlang_version_cached
  [ "$status" -ne 0 ]
}

@test "erlang_version_cached returns false when marker has different version" {
  mkdir -p "$(erlang_cache_dir)"
  echo "26.0" > "$(erlang_cache_dir)/.version"
  run erlang_version_cached
  [ "$status" -ne 0 ]
}

@test "erlang_version_cached returns true when marker matches current version" {
  mkdir -p "$(erlang_cache_dir)"
  echo "27.2" > "$(erlang_cache_dir)/.version"
  run erlang_version_cached
  [ "$status" -eq 0 ]
}

@test "erlang_version_cached detects version change across patch releases" {
  mkdir -p "$(erlang_cache_dir)"
  echo "27.2.1" > "$(erlang_cache_dir)/.version"
  erlang_version="27.2"
  run erlang_version_cached
  [ "$status" -ne 0 ]
}

# --- _mark_erlang_cached ---

@test "_mark_erlang_cached writes version to marker file" {
  mkdir -p "$(erlang_cache_dir)"
  _mark_erlang_cached
  [ "$(cat "$(erlang_cache_dir)/.version")" = "27.2" ]
}

@test "erlang_version_cached returns true after _mark_erlang_cached" {
  mkdir -p "$(erlang_cache_dir)"
  _mark_erlang_cached
  erlang_version_cached
}
