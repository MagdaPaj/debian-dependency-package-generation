# Debian dependency package generation

## Motivation

In device management, it is valuable to have the fleet of devices as consistent as possible. This helps in testing software releases and makes it easier to debug issues on remote devices.

If performing package based updates, one topic to consider is how to avoid drift between the initial device image and the state of the device fleet.

One additional consideration is that APT is very opinionated about which dependent package version to install when resolving dependencies. APT will always try to install the latest available package version that can be found in all source package repositories unless instructed differently using [APT preferences](https://manpages.debian.org/bullseye/apt/apt_preferences.5.en.html).

## Approach with a dependency package

A dependency package represents a desired state of a system, which is defined by a list of Debian packages with corresponding versions. All required packages are captured as dependencies in the control file of an otherwise shallow Debian package. APT will try to automatically resolve and install these dependencies when running `apt install dependency-pack`.

This repository contains pipelines and scripts for generating the Debian dependency package and its optional companion package that modifies the APT preferences to force the installation of the exact version of the dependent package.

The dependency package can be referred to when generating the initial device image and when issuing package updates to the device fleet. This way, the same desired state should be represented in both.

## Structure of dependency packages

Dependency packages consist of a `control` file defining the desired state by enumerating all dependencies in the `Depends: ` section.

```
Package: dependency-pack
Version: 0.0.1
Architecture: amd64
Maintainer: YourName <YourName@YourCompany>
Depends: dependency-a (=1.2.3-1), dependency-b(=1.9.1-3)
Description: Dependency Pack.
 You can add a longer description here. Mind the space at the beginning of this paragraph.
```

## Structure of companion packages

Companion packages consist of a plain `control` file and an additional APT preference file that will be placed under `etc/apt/preferences.d/` during installation. Every dependent package results in an entry with the following structure:

```
Package: aziot-identity-service
Pin: version 1.2.4-1
Pin-Priority: 1001
```

The impact of APT preferences can be inspected by running `apt-cache policy your-package-name`.


## Release creation

To create a new dependency package, a new release must be created. To do so:

1. create a new file under `package-history` folder using the current value of `$EPOCHSECONDS` as a file name
2. in the newly create file, put each package name and its pinned version on a new line, e.g. `package-name (=1.1.0-1)`
3. commit and push your changes
4. create a new tag following the semantic versioning (e.g. `git tag v0.0.5`)
5. push the tag `git push --tags`, this will automatically trigger a GitHub workflow that will create a new release with the dependency and companion package as assets.

## Package installation

Download the dependency package from a selected release. To install it, run:

```bash
sudo apt install ./dependency-pack.deb
```

If there is an error with unmet dependencies because APT would like to install a newer version of a dependent package, you have multiple options to force the installation of the pinned versions.

1. Install the companion package first
```bash
sudo apt install ./pinning-pack.deb
sudo apt install ./dependency-pack.deb
```

2. Inspect the dependency list manually and install every dependent package explicitly
```bash
dpkg-deb -f ./dependency-pack.deb control Depends
sudo apt install ./dependency-pack.deb dependency-a=1.2.3-1 dependency-b=1.9.1-3
```

3. Use private repositories as package sources and make sure they only contain packages that match the dependent packages' versions.


## Pipelines

### Azure DevOps
The sample Azure DevOps [pipeline](./.azdo/pipelines/release-packages.yml) shows how to generate and publish dependency/pinning packages to Artifactory. It assumes that multiple distinct environments are targeted: DEV, TEST, PROD. For each of these environments, a distinct variable group needs to be preconfigured in Azure DevOps. Each of these groups is expected to contain the following variables:
- ARTIFACTORY-USERNAME: The username authorized to push packages to Artifactory
- ARTIFACTORY-PASSWORD: The password authenticating the ARTIFACTORY-USERNAME
- ARTIFACTORY-URL: The base URL of the targeted Artifactory instance, e.g. https://{your-instance}.jfrog.io/artifactory/{your-repository}

The TEST and PROD stages require the manual approval of an authorized Azure DevOps user before they are executed.

In order to allow the pipeline to push the tag to the GIT repository, make sure to allow the "Build Service" to contribute to the corresponding repository (AzDo->Project Settings->Repositories->{Your Repo}->Security->{* Build Service}->Contribute->Allow).

### GitHub
The sample GitHub [workflow](./.github/workflows/generate-package.yml) shows how to generate and publish dependency/pinning packages using the built-in GitHub Releases.