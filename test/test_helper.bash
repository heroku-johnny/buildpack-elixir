#!/usr/bin/env bash

BUILDPACK_ROOT="$(cd "$(dirname "${BATS_TEST_FILENAME}")/../.." && pwd)"

# Source a lib module with required variables pre-set for testing.
load_lib() {
  source "${BUILDPACK_ROOT}/lib/output.sh"
  source "${BUILDPACK_ROOT}/lib/paths.sh"
  source "${BUILDPACK_ROOT}/lib/stack.sh"
  source "${BUILDPACK_ROOT}/lib/${1}"
}

# Create a temporary directory, export build/cache/env path variables,
# and register cleanup on test teardown.
setup_test_dirs() {
  TEST_TMPDIR=$(mktemp -d)
  build_path="${TEST_TMPDIR}/build"
  cache_path="${TEST_TMPDIR}/cache"
  env_path="${TEST_TMPDIR}/env"
  runtime_path="/app"
  mkdir -p "${build_path}" "${cache_path}" "${env_path}"
}

teardown_test_dirs() {
  rm -rf "${TEST_TMPDIR}"
}
