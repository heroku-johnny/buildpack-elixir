#!/usr/bin/env bash

output_section() {
  echo "-----> $1"
}

output_line() {
  echo "       $1"
}

output_warning() {
  echo -e "       \e[33mWARNING: $1\e[0m"
}

output_error() {
  echo -e "       \e[31mERROR: $1\e[0m" >&2
}
