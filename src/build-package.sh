#!/bin/bash

set -euxo pipefail

if [ "$#" -ne 3 ]
then
	echo "Script requires 3 parameters: 'path to package folder', 'path to output folder', `tag version`"
	exit 1
fi

packageFolder=$(cd $1 && pwd)
outputFolder=$(mkdir -p $2 && cd $2 && pwd)
tagVersion=$3

echo $tagVersion

cd $packageFolder
origin=$(ls --sort=version | head -n 1)
current=$(ls --sort=version | tail -n 1)
comm -13 $origin $current >> delta
added=$(cat delta | tr '\n' ',')
echo "Added $added"

removed=$(comm -23 $origin $current | tr '\n' ',')
echo "Removed $removed"

mkdir -p $outputFolder/dependency-pack/DEBIAN
cd $outputFolder/dependency-pack/DEBIAN

echo "Package: dependency-pack" > control
echo "Version: $tagVersion-$current" >> control
echo "Architecture: $(dpkg --print-architecture)" >> control
echo "Maintainer: YourName <YourName@YourCompany>" >> control
echo "Depends: $([ -z "$added" ] && echo $added || echo ${added::-1}),dependency-pack-pinning (=$tagVersion-$current)" >> control
echo "Description: Dependency Pack." >> control

dpkg-deb --build --root-owner-group "$outputFolder/dependency-pack"

mkdir -p $outputFolder/dependency-pack-pinning/DEBIAN
cd $outputFolder/dependency-pack-pinning/DEBIAN

echo "Package: dependency-pack-pinning" > control
echo "Version: $tagVersion-$current" >> control
echo "Architecture: $(dpkg --print-architecture)" >> control
echo "Maintainer: YourName <YourName@YourCompany>" >> control
echo "Description: Dependency Package Version Pinning." >> control

mkdir -p $outputFolder/dependency-pack-pinning/etc/apt/preferences.d
cd $outputFolder/dependency-pack-pinning/etc/apt/preferences.d
touch 1001-honor-dependency-pack

while IFS= read -r line
do
	package=$(echo $line | sed 's/\(.*\)(=.*)/\1/')
	version=$(echo $line | sed 's/.*(=\(.*\))/\1/')
	echo "Package: $package" > 1001-honor-dependency-pack
	echo "Pin: version $version" >> 1001-honor-dependency-pack
	echo "Pin-Priority: 1001" >> 1001-honor-dependency-pack
	echo "" >> 1001-honor-dependency-pack
done < "$packageFolder/delta"

rm $packageFolder/delta

dpkg-deb --build --root-owner-group "$outputFolder/dependency-pack-pinning"