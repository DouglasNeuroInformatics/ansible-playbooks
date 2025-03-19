#!/usr/bin/env bash

if command -v micromamba &>/dev/null; then
  eval "$(micromamba shell hook --shell=bash)"
fi
