set -e

echo "\n#### Running tests"

diff -y --suppress-common-lines build/ tests/expected/

echo "#### Tests pass"
exit 0