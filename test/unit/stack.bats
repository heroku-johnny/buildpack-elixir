#!/usr/bin/env bats

load "../test_helper"

setup() {
  source "${BUILDPACK_ROOT}/lib/output.sh"
  source "${BUILDPACK_ROOT}/lib/paths.sh"
  source "${BUILDPACK_ROOT}/lib/stack.sh"
}

# --- otp_base_url ---

@test "otp_base_url returns ubuntu-22.04 path for heroku-22" {
  STACK="heroku-22"
  run otp_base_url
  [ "$status" -eq 0 ]
  [[ "$output" == *"ubuntu-22.04"* ]]
}

@test "otp_base_url returns ubuntu-24.04 path for heroku-24" {
  STACK="heroku-24"
  run otp_base_url
  [ "$status" -eq 0 ]
  [[ "$output" == *"ubuntu-24.04"* ]]
}

@test "otp_base_url returns ubuntu-26.04 path for heroku-26" {
  STACK="heroku-26"
  run otp_base_url
  [ "$status" -eq 0 ]
  [[ "$output" == *"ubuntu-26.04"* ]]
}

@test "otp_base_url exits 1 for unknown stack" {
  STACK="heroku-99"
  run otp_base_url
  [ "$status" -eq 1 ]
}

# --- stack_otp_minimum ---

@test "stack_otp_minimum is 24 for heroku-22" {
  STACK="heroku-22"
  [ "$(stack_otp_minimum)" = "24" ]
}

@test "stack_otp_minimum is 24 for heroku-24" {
  STACK="heroku-24"
  [ "$(stack_otp_minimum)" = "24" ]
}

@test "stack_otp_minimum is 26 for heroku-26" {
  STACK="heroku-26"
  [ "$(stack_otp_minimum)" = "26" ]
}

# --- validate_otp_for_stack ---

@test "validate_otp_for_stack passes OTP 27.2 on heroku-22" {
  STACK="heroku-22"
  run validate_otp_for_stack "27.2"
  [ "$status" -eq 0 ]
}

@test "validate_otp_for_stack passes OTP 24.2 on heroku-22" {
  STACK="heroku-22"
  run validate_otp_for_stack "24.2"
  [ "$status" -eq 0 ]
}

@test "validate_otp_for_stack rejects OTP 24.1 on heroku-22" {
  STACK="heroku-22"
  run validate_otp_for_stack "24.1"
  [ "$status" -eq 1 ]
  [[ "$output" == *"not available for heroku-22"* ]]
}

@test "validate_otp_for_stack rejects OTP 24.0 on heroku-22" {
  STACK="heroku-22"
  run validate_otp_for_stack "24.0"
  [ "$status" -eq 1 ]
}

@test "validate_otp_for_stack rejects OTP 24.x on heroku-26" {
  STACK="heroku-26"
  run validate_otp_for_stack "24.3.4"
  [ "$status" -eq 1 ]
  [[ "$output" == *"not available for heroku-26"* ]]
}

@test "validate_otp_for_stack rejects OTP 25.x on heroku-26" {
  STACK="heroku-26"
  run validate_otp_for_stack "25.3"
  [ "$status" -eq 1 ]
}

@test "validate_otp_for_stack passes OTP 26.0 on heroku-26" {
  STACK="heroku-26"
  run validate_otp_for_stack "26.0"
  [ "$status" -eq 0 ]
}

@test "validate_otp_for_stack rejects OTP 24.2 on heroku-24" {
  STACK="heroku-24"
  run validate_otp_for_stack "24.2"
  [ "$status" -eq 1 ]
  [[ "$output" == *"not available for heroku-24"* ]]
}

@test "validate_otp_for_stack passes OTP 24.3.4 on heroku-24" {
  STACK="heroku-24"
  run validate_otp_for_stack "24.3.4"
  [ "$status" -eq 0 ]
}

@test "validate_otp_for_stack error message includes builds.txt URL" {
  STACK="heroku-26"
  run validate_otp_for_stack "24.3.4"
  [ "$status" -eq 1 ]
  [[ "$output" == *"builds.txt"* ]]
}

@test "validate_otp_for_stack error message does not mention update action" {
  STACK="heroku-26"
  run validate_otp_for_stack "24.3.4"
  [ "$status" -eq 1 ]
  [[ "$output" == *"elixir_buildpack.config"* ]]
}

# --- version_gte ---

@test "version_gte: 27.2 >= 26.0 is true" {
  run version_gte "27.2" "26.0"
  [ "$status" -eq 0 ]
}

@test "version_gte: 24.3.4 >= 24.3.4 is true" {
  run version_gte "24.3.4" "24.3.4"
  [ "$status" -eq 0 ]
}

@test "version_gte: 24.2 >= 24.3.4 is false" {
  run version_gte "24.2" "24.3.4"
  [ "$status" -ne 0 ]
}
