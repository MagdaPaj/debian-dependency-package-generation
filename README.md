# Debian dependency package generation

A dependency package represents a desired state of a system, which is defined by a list of Debian packages with corresponding versions. All required packages are captured as dependencies in a new Debian package.

This repository contains pipelines for generating the Debian dependency package.

## Structure of dependency packages

Dependency packages consist of a `control` file defining the desired state.

```bash
Package: dependency-pack
Version: 0.0.1
Architecture: amd64
Maintainer: YourName <YourName@YourCompany>
Depends: dependency-a (=1.2.3-1), dependency-b(=1.9.1-3)
Description: Dependency Pack.
 You can add a longer description here. Mind the space at the beginning of this paragraph.
```

## Release creation

To create a new dependency package a new release must be created. To do so:

1. create a new file under `package-history` folder with the epoch time as a file name
2. define in the file your package list containing package names and versions
3. commit and push your changes
4. create a new tag following the semantic versioning (e.g. `git tag v0.0.5`)
5. push the tag `git push --tags`, this will automatically trigger a GitHub workflow that will create a new release with a dependency package as an asset.

## Package installation

Download the dependency package from a selected release. To install it, run:

```bash
sudo apt install ./dependency-pack.deb
```

If there is an error with unmet dependencies, you also need to add packages with their exact version from the `Depends` list to the above command. To get the `Depends` list:

```bash
dpkg-deb -f ./dependency-pack.deb control Depends
```

Command syntax:

```bash
sudo apt install ./dependency-pack.deb dependency-a=1.2.3-1 dependency-b=1.9.1-3
```
