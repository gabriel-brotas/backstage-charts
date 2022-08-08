mkdir -p build

for d in charts/*; do
  chart="${d##*/}"
  helm dependency update "${d}"
  if [ -f "${d}/values-secrets.yaml" ]; then
    helm template -f values.yaml -f "${d}/values-secrets.yaml" "${chart}" "${d}" >build/"${chart}"-deployment.yml
  else
    helm template -f values.yaml "${chart}" "${d}" >build/"${chart}"-deployment.yml
  fi
done

exit 0
