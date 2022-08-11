#!/usr/bin/env bash

while getopts c:t:f: flag
do
    case "${flag}" in
        c) chart=${OPTARG};;
        t) tag=${OPTARG};;
        f) field=${OPTARG};;
    esac
done

echo "Chart: $chart";
echo "Tag: $tag";
echo "Field: $field";

BASEDIR=$(dirname $0)
cd $BASEDIR

cd ../charts/$chart

# yq -i e '.backstage.image.tag |= "1.xx"' values.yaml
yq -i e ''$field' |= "'$tag'"' values.yaml

exit 0
