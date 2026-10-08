#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2154  # MIX_HOME, HEX_HOME set by bin/compile before sourcing

install_hex() {
  output_section "Installing Hex"
  # HEX_UNSAFE_HTTPS: OTP 25+ strict TLS validation rejects the key_usage_mismatch
  # in the builds.hex.pm cert chain. Hex verifies package integrity by hash
  # independently of HTTPS, so this does not compromise package authenticity.
  HEX_UNSAFE_HTTPS=1 mix local.hex --force --quiet
}

install_rebar() {
  output_section "Installing rebar"
  HEX_UNSAFE_HTTPS=1 mix local.rebar --force --quiet
}
