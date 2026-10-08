#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2154  # MIX_HOME, HEX_HOME set by bin/compile before sourcing

install_hex() {
  output_section "Installing Hex"
  # HEX_CACERTS_PATH: Mix.Utils.read_httpc uses public_key:cacerts_get() by
  # default, which on OTP 25+ may include cross-signed certs that trigger the
  # strict key_usage_mismatch check against builds.hex.pm. Pointing to the
  # system CA bundle directly uses the clean Ubuntu cert store instead.
  HEX_CACERTS_PATH=/etc/ssl/certs/ca-certificates.crt \
    mix local.hex --force --quiet
}

install_rebar() {
  output_section "Installing rebar"
  HEX_CACERTS_PATH=/etc/ssl/certs/ca-certificates.crt \
    mix local.rebar --force --quiet
}
