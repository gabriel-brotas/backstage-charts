set -e

echo "\n#### Running validation"

docker run -v "$(pwd):/home/sourcehawk" optumopensource/sourcehawk:0.6.0 scan

echo "#### Validation pass"
exit 0