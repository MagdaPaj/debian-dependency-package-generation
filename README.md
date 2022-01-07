# Debian dependency package generation

A dependency package represents a desired state of a system, which is defined by a list of Debian packages with corresponding versions. All required packages are captured as dependencies in a new Debian package.

This repository contains pipelines for generating the Debian dependency package.

# Structure of dependency packages
Dependency packages consist of a `control` file defining the desired state.
```
Package: dependency-pack
Version: 0.0.1
Architecture: amd64
Maintainer: YourName <YourName@YourCompany>
Depends: dependency-a (=1.2.3-1), dependency-b(=1.9.1-3)
Description: Dependency Pack.
 You can add a longer description here. Mind the space at the beginning of this paragraph.
```