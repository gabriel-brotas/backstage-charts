set -e

exit 0

echo "\n#### Deploying Charts"

echo "EKS_NAMESPACE=$EKS_NAMESPACE"
echo "VERSION=${VERSION}"
echo ""

if [[ -z "$EKS_NAMESPACE" ]]; then
    echo "Must provide EKS_NAMESPACE in environment" 1>&2
    exit 1
fi

for d in charts/* ; do
  chart="${d##*/}"
  echo "Upgrading chart $chart"
  helm upgrade -f values.yaml --namespace="$EKS_NAMESPACE" --install "${chart}" "${d}"
done