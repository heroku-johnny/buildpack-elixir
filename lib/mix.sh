#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2154  # MIX_HOME, HEX_HOME set by bin/compile before sourcing

install_hex() {
  output_section "Installing Hex"
  # Try the standard path first — works on subsequent builds when hex is cached,
  # and on stacks where builds.hex.pm's TLS cert chain is accepted by OTP.
  # OTP 25+ strict key_usage_mismatch validation rejects builds.hex.pm's chain
  # on some stacks; fall back to GitHub which uses a clean DigiCert chain.
  # hex has no external Mix deps so compilation is self-contained.
  if ! mix local.hex --force --quiet 2>/dev/null; then
    output_line "Fetching Hex from GitHub (builds.hex.pm TLS cert chain workaround)"
    mix archive.install github hexpm/hex branch latest --force || {
      output_error "Failed to install Hex."
      output_line "See: https://hexdocs.pm/mix/Mix.Tasks.Local.Hex.html"
      exit 1
    }
  fi
}

install_rebar() {
  output_section "Installing rebar"
  if ! mix local.rebar --force --quiet 2>/dev/null; then
    output_warning "rebar3 install failed — only required for Erlang dependencies."
  fi
}
