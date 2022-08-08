#!/usr/bin/env bash

mkdir -p build
mkdir -p tests/expected

for d in charts/*; do
  chart="${d##*/}"
  if [ -f "./${d}/values-secrets.yaml" ]; then
    helm template -f values.yaml -f "${d}/values-secrets.yaml" -f tests/values.yaml "${chart}" "${d}" >tests/expected/${chart}-deployment.yml
  else
    helm template -f values.yaml -f tests/values.yaml "${chart}" "${d}" >tests/expected/${chart}-deployment.yml
  fi
done

exit 0
