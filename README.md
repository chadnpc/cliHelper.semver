# [cliHelper.semver](https://www.powershellgallery.com/packages/cliHelper.semver)

PowerShell module for robust and type-safe [Semantic Versioning](https://github.com/semver/semver).


[![Build Module](https://github.com/chadnpc/cliHelper.semver/actions/workflows/build_module.yaml/badge.svg)](https://github.com/chadnpc/cliHelper.semver/actions/workflows/build_module.yaml)
[![Downloads](https://img.shields.io/powershellgallery/dt/cliHelper.semver.svg?style=flat&logo=powershell&color=blue)](https://www.powershellgallery.com/packages/cliHelper.semver)

## Usage

First, install and import the module:

```PowerShell
Install-Module cliHelper.semver
Import-Module cliHelper.semver
```

Once imported, you can use the cmdlets to work with Semantic Versions.

### Creating Semanticver Objects

You can create `Semanticver` objects in a few ways:

**1. Using `New-SemanticVersion` with a version string:**

```PowerShell
$version = New-SemanticVersion -VersionString "1.2.3-alpha+build123"
$version
```

**Output:**

```
Major            : 1
Minor            : 2
Patch            : 3
PreRelease       : alpha
Build            : build123
```

**2. Using `New-SemanticVersion` with individual components:**

```PowerShell
$version = New-SemanticVersion -Major 2 -Minor 0 -Patch 0 -PreRelease "rc.2"
$version
```

**Output:**

```
Major            : 2
Minor            : 0
Patch            : 0
PreRelease       : rc.2
Build            :
```

**3. Using `ConvertTo-SemanticVersion` from a string:**

```PowerShell
$versionString = "3.1.4+meta.info"
$version = ConvertTo-SemanticVersion -InputObject $versionString
$version
```

**Output:**

```
Major            : 3
Minor            : 1
Patch            : 4
PreRelease       :
Build            : meta.info
```

### Validating Semantic Versions

Use `Test-SemanticVersion` to check if a string is a valid SemVer string:

```PowerShell
Test-SemanticVersion -VersionString "1.5.0"
# Output: True

Test-SemanticVersion -VersionString "invalid-version-format"
# Output: False
```

### Incrementing Version Components

Increment specific parts of a `Semanticver` object using `Step-SemanticVersion`:

```PowerShell
$version = New-SemanticVersion -VersionString "1.2.3-beta"
$incrementedVersion = Step-SemanticVersion -Version $version -Component Minor
$incrementedVersion
```

**Output:**

```
Major            : 1
Minor            : 3
Patch            : 0
PreRelease       :
Build            :
```

You can increment `Major`, `Minor`, `Patch`, `PreReleaseIdentifier`, or `BuildMetadata` components.

### Getting Version Components

Retrieve individual components from a `Semanticver` object with `Get-SemanticVersionComponent`:

```PowerShell
$version = New-SemanticVersion -VersionString "2.5.7-rc.1+build.99"
Get-SemanticVersionComponent -Version $version -Component PreReleaseIdentifier
# Output: rc.1

Get-SemanticVersionComponent -Version $version -Component Major
# Output: 2
```

### Comparing Semantic Versions

Compare two `Semanticver` objects using `Compare-SemanticVersion` to determine their precedence:

```PowerShell
$version1 = New-SemanticVersion -VersionString "1.0.0-alpha"
$version2 = New-SemanticVersion -VersionString "1.0.0-beta"
$comparisonResult = Compare-SemanticVersion -ReferenceVersion $version1 -DifferenceVersion $version2
$comparisonResult
```

**Output (PrecedenceComparisonResult Enum):**

```
Lower
```

This will output `Lower`, `Equal`, or `Higher` based on SemVer precedence rules.

These examples provide a basic overview of how to use the `cliHelper.semver` module.  Refer to the help documentation for each cmdlet (`Get-Help CmdletName -Full`) for more detailed information and advanced usage.

## License

This project is licensed under the [WTFPL License](LICENSE).