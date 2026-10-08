#!/usr/bin/env bash
# shellcheck shell=bash
# shellcheck disable=SC2154  # MIX_HOME, HEX_HOME set by bin/compile before sourcing

install_hex() {
  output_section "Installing Hex"
  mix local.hex --force --quiet
}

install_rebar() {
  output_section "Installing rebar"
  mix local.rebar --force --quiet
}
