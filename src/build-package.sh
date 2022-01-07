#!/bin/bash

set -euxo pipefail

if [ "$#" -ne 2 ]
then
	echo "Script requires 2 parameters: 'path to package folder', 'path to output folder'"
	exit 1
fi

packageFolder=$(cd $1 && pwd)
outputFolder=$(mkdir -p $2 && cd $2 && pwd)

cd $packageFolder
origin=$(ls --sort=version | head -n 1)
current=$(ls --sort=version | tail -n 1)
added=$(comm -13 $origin $current | tr '\n' ', ')
echo "Added $added"

removed=$(comm -23 $origin $current | tr '\n' ', ')
echo "Removed $removed"

mkdir -p $outputFolder/dependency-pack/DEBIAN
cd $outputFolder/dependency-pack/DEBIAN

echo "Package: dependency-pack" > control
echo "Version: 0.0.1-$current" >> control
echo "Architecture: amd64" >> control
echo "Maintainer: YourName <YourName@YourCompany>" >> control
echo "Depends: $([ -z "$added" ] && echo $added || echo ${added::-1})" >> control
echo "Description: Dependency Pack." >> control