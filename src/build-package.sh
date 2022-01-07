#!/bin/bash

set -euxo pipefail

if [ "$#" -ne 1 ]
then
	echo "Script requires 1 parameter: 'path to package folder'"
	exit 1
fi

cd $1
origin=$(ls | head -n 1)
current=$(ls | tail -n 1)
added=$(comm -13 $origin $current)
echo "Added [$added]"

removed=$(comm -23 $origin $current)
echo "Removed [$removed]"