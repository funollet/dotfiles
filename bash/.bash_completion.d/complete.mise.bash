#!/bin/bash

if which mise >/dev/null 2>&1; then
  source <(mise completion bash)
fi
