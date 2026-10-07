#!/usr/bin/env bats

load "../test_helper"

setup() {
  source "${BUILDPACK_ROOT}/lib/output.sh"
}

@test "output_section prefixes with '----->' " {
  run output_section "Installing Erlang"
  [ "$status" -eq 0 ]
  [[ "$output" == "----->"* ]]
  [[ "$output" == *"Installing Erlang"* ]]
}

@test "output_line indents with spaces" {
  run output_line "OTP 27.2"
  [ "$status" -eq 0 ]
  [[ "$output" == "       "* ]]
  [[ "$output" == *"OTP 27.2"* ]]
}

@test "output_warning includes WARNING label" {
  run output_warning "something deprecated"
  [ "$status" -eq 0 ]
  [[ "$output" == *"WARNING"* ]]
  [[ "$output" == *"something deprecated"* ]]
}

@test "output_error writes to stderr" {
  run bash -c "source ${BUILDPACK_ROOT}/lib/output.sh; output_error 'something failed'"
  [ "$status" -eq 0 ]
  [[ "$output" == *"ERROR"* ]]
  [[ "$output" == *"something failed"* ]]
}
