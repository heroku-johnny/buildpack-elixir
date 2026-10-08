#!/usr/bin/env bash

# OTP download base URL for the current stack.
otp_base_url() {
  case "${STACK}" in
    heroku-22) echo "https://builds.hex.pm/builds/otp/ubuntu-22.04" ;;
    heroku-24) echo "https://builds.hex.pm/builds/otp/ubuntu-24.04" ;;
    heroku-26) echo "https://builds.hex.pm/builds/otp/ubuntu-26.04" ;;
    *)
      output_error "Stack '${STACK}' is not supported. Supported stacks: heroku-22, heroku-24, heroku-26."
      exit 1
      ;;
  esac
}

# Minimum OTP major version required for the current stack.
# heroku-26 has no OTP 24 or 25 builds available.
# heroku-24 has no OTP 24.0–24.2 builds available.
stack_otp_minimum() {
  case "${STACK}" in
    heroku-22) echo "24" ;;
    heroku-24) echo "24" ;;
    heroku-26) echo "26" ;;
  esac
}

# Minimum OTP patch version for stacks where not all builds in a major series exist.
# Returns an empty string when the major version alone is sufficient.
stack_otp_minimum_patch() {
  case "${STACK}" in
    heroku-22) echo "24.2" ;;
    heroku-24) echo "24.3.4" ;;
    *) echo "" ;;
  esac
}

# Validate that the requested OTP version meets the stack minimum.
# Exits with a clear error if not.
validate_otp_for_stack() {
  local version="$1"
  local major
  major=$(echo "$version" | cut -d. -f1)

  local min_major
  min_major=$(stack_otp_minimum)

  if [ "$major" -lt "$min_major" ] 2>/dev/null; then
    local min_patch
    min_patch=$(stack_otp_minimum_patch)
    local display_min="${min_patch:-${min_major}.x}"
    output_error "OTP ${version} is not available for ${STACK}."
    output_line "The minimum supported OTP version for ${STACK} is ${display_min}."
    output_line "Update erlang_version in your elixir_buildpack.config."
    output_line "Available versions: $(otp_base_url)/builds.txt"
    exit 1
  fi

  # Some stacks only have a subset of builds within a major OTP series.
  local min_patch
  min_patch=$(stack_otp_minimum_patch)
  local min_patch_major
  min_patch_major=$(echo "$min_patch" | cut -d. -f1)
  if [ -n "$min_patch" ] && [ "$major" -eq "$min_patch_major" ]; then
    if ! version_gte "$version" "$min_patch"; then
      output_error "OTP ${version} is not available for ${STACK}."
      output_line "The minimum supported OTP 24.x version for ${STACK} is ${min_patch}."
      output_line "Update erlang_version in your elixir_buildpack.config."
      output_line "Available versions: $(otp_base_url)/builds.txt"
      exit 1
    fi
  fi
}

# Compare two version strings. Returns 0 if $1 >= $2.
version_gte() {
  local a="$1" b="$2"
  # Use sort -V to determine order
  [ "$(printf '%s\n%s' "$a" "$b" | sort -V | head -1)" = "$b" ]
}
