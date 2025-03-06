# [cliHelper.semver](https://www.powershellgallery.com/packages/cliHelper.semver)

PowerShell module for robust and type-safe [Semantic Versioning](https://github.com/semver/semver).

[![Build Module](https://github.com/chadnpc/cliHelper.semver/actions/workflows/build_module.yaml/badge.svg)](https://github.com/chadnpc/cliHelper.semver/actions/workflows/build_module.yaml)
[![Downloads](https://img.shields.io/powershellgallery/dt/cliHelper.semver.svg?style=flat&logo=powershell&color=blue)](https://www.powershellgallery.com/packages/cliHelper.semver)

## Usage

First:

```PowerShell
Install-Module cliHelper.semver
 Import-Module cliHelper.semver
```

Once imported,

- **Create version Objects**

  ```PowerShell
  # You can create [Semanticver] objects in a few ways:
  #+ 1. Using `New-SemanticVersion` with a version string:
  $version = New-SemanticVersion -VersionString "1.2.3-alpha+build123"
  $version
  #Output:
  #goes here
  #
  # + 2. Using `New-SemanticVersion` with individual components:**
  $version = New-SemanticVersion -Major 2 -Minor 0 -Patch 0 -PreRelease "rc.2"
  $version
  #Output:
  #goes here
  #+3. Using `ConvertTo-SemanticVersion` from a string:**
  $versionString = "3.1.4+meta.info"
  $version = ConvertTo-SemanticVersion -InputObject $versionString
  $version
  ```


- **Validate Semantic Versions**

  ```PowerShell
  Test-SemanticVersion -VersionString "1.5.0"
  # Output: True

  Test-SemanticVersion -VersionString "invalid-version-format"
  # Output: False
  ```

- **Increment Version Components**

  ```PowerShell
  $version = New-SemanticVersion -VersionString "1.2.3-beta"
  $incrementedVersion = Step-SemanticVersion -Version $version -Component Minor
  $incrementedVersion
  ```

  You can increment `Major`, `Minor`, `Patch`, `PreReleaseIdentifier`, or `BuildMetadata` components.


- **Retrieve individual components**

  ```PowerShell
  $version = New-SemanticVersion -VersionString "2.5.7-rc.1+build.99"
  Get-SemanticVersionComponent -Version $version -Component PreReleaseIdentifier
  # Output: rc.1

  Get-SemanticVersionComponent -Version $version -Component Major
  # Output: 2
  ```

- **Compare versions**

  ```PowerShell
  $version1 = New-SemanticVersion -VersionString "1.0.0-alpha"
  $version2 = New-SemanticVersion -VersionString "1.0.0-beta"
  $comparisonResult = Compare-SemanticVersion -ReferenceVersion $version1 -DifferenceVersion $version2
  $comparisonResult
  ```
  This will output `Lower`, `Equal`, or `Higher` based on SemVer precedence rules.

## License

This project is licensed under the [WTFPL License](LICENSE).