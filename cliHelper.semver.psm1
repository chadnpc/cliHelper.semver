#!/usr/bin/env pwsh
using namespace System
using namespace System.management.automation
using namespace System.ComponentModel.TypeConverter
using namespace Microsoft.PackageManagement.Provider.Utility

#region    Classes
enum VersionComponent {
  Major
  Minor
  Patch
  PreReleaseIdentifier
  BuildMetadata
}

enum PrecedenceComparisonResult {
  Lower
  Equal
  Higher
}


<#
.SYNOPSIS
  Main class
.EXAMPLE
  # Parse a version
  $semver = [Semanticver]::Parse("1.2.3-alpha+build123")

  # Increment the minor version
  $incrementedSemver = [Semanticver]::Increment($semver, [VersionComponent]::Minor)
  Write-Host "Incremented Minor: $($incrementedSemver.ToString())" # Output: 1.3.0

  # Get the Patch component
  $patchVersion = [Semanticver]::GetComponent($semver, [VersionComponent]::Patch)
  Write-Host "Patch Version: $patchVersion" # Output: 3

  # Parse another version for comparison
  $semver2 = [Semanticver]::Parse("1.3.0")

  # Compare Minor components
  $comparisonResult = [Semanticver]::CompareComponent($semver, $semver2, [VersionComponent]::Minor)
  Write-Host "Minor Component Comparison: $comparisonResult" # Output: Lower (because 1.2.3 vs 1.3.0)
#>
class Semanticver {
  [int]$Major
  [int]$Minor
  [string]$Build
  [int]$Patch
  [string]$PreRelease
  static [string]$SemanticVersionPattern = '^(0|[1-9]\d*)\.(0|[1-9]\d*)\.(0|[1-9]\d*)(?:-((?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*)(?:\.(?:0|[1-9]\d*|\d*[a-zA-Z-][0-9a-zA-Z-]*))*))?(?:\+([0-9a-zA-Z-]+(?:\.[0-9a-zA-Z-]+)*))?$'
  Semanticver() {
    $this.Major = 0
    $this.Minor = 0
    $this.Patch = 0
    $this.PreRelease = ""
    $this.Build = ""
  }

  static [Semanticver] Parse([string]$versionString) {
    if (![Semanticver]::IsValid($versionString)) {
      throw "Invalid SemVer string: '$versionString'"
    }
    $local:matches = @{}
    if ($versionString -match [regex]::Escape([Semanticver]::SemanticVersionPattern) -and $matches.Count -gt 0) {
      $semver = [Semanticver]::new()
      $semver.Major = [int]::Parse($matches.1)
      $semver.Minor = [int]::Parse($matches.2)
      $semver.Patch = [int]::Parse($matches.3)
      $semver.PreRelease = $matches.4
      $semver.Build = $matches.5
      return $semver
    }
    # Should not reach here if IsValid is working correctly, but for safety:
    throw "Failed to parse SemVer string: '$versionString'"
  }

  # checks if a string is a valid semantic version
  static [bool] IsValid([string]$versionString) {
    return $versionString -match [regex]::Escape([Semanticver]::SemanticVersionPattern)
  }

  [string] ToString() {
    $version = "$($this.Major).$($this.Minor).$($this.Patch)"
    if (![string]::IsNullOrEmpty($this.PreRelease)) {
      $version += "-$($this.PreRelease)"
    }
    if (![string]::IsNullOrEmpty($this.Build)) {
      $version += "+$($this.Build)"
    }
    return $version
  }
  # Increments a version component
  static [Semanticver] Increment([Semanticver]$version, [VersionComponent]$component) {
    $newVersion = [Semanticver]::Parse($version.ToString()) # Create a copy to avoid modifying the original object
    switch ($component.ToString()) {
      "Major" {
        $newVersion.Major++
        $newVersion.Minor = 0
        $newVersion.Patch = 0
        $newVersion.PreRelease = ""
      }
      "Minor" {
        $newVersion.Minor++
        $newVersion.Patch = 0
        $newVersion.PreRelease = ""
      }
      "Patch" {
        $newVersion.Patch++
        $newVersion.PreRelease = ""
      }
      "PreReleaseIdentifier" {
        # For now, simply clear prerelease. More sophisticated logic can be added later.
        $newVersion.PreRelease = ""
      }
      "BuildMetadata" {
        # Build metadata is usually not incremented in SemVer, but you could add logic here if needed.
        # For now, we'll leave it as is.
      }
      default {
        throw "Unsupported VersionComponent for Increment: '$component'"
      }
    }
    return $newVersion
  }
  static [object] GetComponent([Semanticver]$version, [VersionComponent]$component) {
    $result = switch ($component.ToString()) {
      "Major" { $version.Major; break }
      "Minor" { $version.Minor; break }
      "Patch" { $version.Patch; break }
      "PreReleaseIdentifier" { $version.PreRelease; break }
      "BuildMetadata" { $version.Build; break }
      default {
        throw "Unsupported VersionComponent for GetComponent: '$component'"
      }
    }
    return $result
  }

  # Compares a specific version component
  static [PrecedenceComparisonResult] CompareComponent([Semanticver]$version1, [Semanticver]$version2, [VersionComponent]$component) {
    $result = switch ($component.ToString()) {
      "Major" {
        if ($version1.Major -lt $version2.Major) { "Lower" }
        elseif ($version1.Major -gt $version2.Major) { "Higher" }
        else { "Equal" }
        break
      }
      "Minor" {
        if ($version1.Minor -lt $version2.Minor) { "Lower" }
        elseif ($version1.Minor -gt $version2.Minor) { "Higher" }
        else { "Equal" }
        break
      }
      "Patch" {
        if ($version1.Patch -lt $version2.Patch) { "Lower" }
        elseif ($version1.Patch -gt $version2.Patch) { "Higher" }
        else { "Equal" }
        break
      }
      "PreReleaseIdentifier" {
        # For now, simple string comparison. More complex SemVer prerelease comparison can be added.
        $comparison = [string]::Compare($version1.PreRelease, $version2.PreRelease, [StringComparer]::InvariantCultureIgnoreCase)
        if ($comparison -lt 0) { "Lower" }
        elseif ($comparison -gt 0) { "Higher" }
        else { "Equal" }
        break
      }
      "BuildMetadata" {
        # Build metadata is not considered in SemVer precedence, so always Equal for comparison purposes in this context.
        "Equal"
        break
      }
      default {
        throw "Unsupported VersionComponent for CompareComponent: '$component'"
      }
    }
    return $result
  }
}

#endregion Classes

# Types that will be available to users when they import the module.
$typestoExport = @(
  [Semanticver], [VersionComponent], [PrecedenceComparisonResult]
)
$TypeAcceleratorsClass = [PsObject].Assembly.GetType('System.Management.Automation.TypeAccelerators')
foreach ($Type in $typestoExport) {
  if ($Type.FullName -in $TypeAcceleratorsClass::Get.Keys) {
    $Message = @(
      "Unable to register type accelerator '$($Type.FullName)'"
      'Accelerator already exists.'
    ) -join ' - '
    "TypeAcceleratorAlreadyExists $Message" | Write-Debug
  }
}
# Add type accelerators for every exportable type.
foreach ($Type in $typestoExport) {
  $TypeAcceleratorsClass::Add($Type.FullName, $Type)
}
# Remove type accelerators when the module is removed.
$MyInvocation.MyCommand.ScriptBlock.Module.OnRemove = {
  foreach ($Type in $typestoExport) {
    $TypeAcceleratorsClass::Remove($Type.FullName)
  }
}.GetNewClosure();

$scripts = @();
$Public = Get-ChildItem "$PSScriptRoot/Public" -Filter "*.ps1" -Recurse -ErrorAction SilentlyContinue
$scripts += Get-ChildItem "$PSScriptRoot/Private" -Filter "*.ps1" -Recurse -ErrorAction SilentlyContinue
$scripts += $Public

foreach ($file in $scripts) {
  Try {
    if ([string]::IsNullOrWhiteSpace($file.fullname)) { continue }
    . "$($file.fullname)"
  } Catch {
    Write-Warning "Failed to import function $($file.BaseName): $_"
    $host.UI.WriteErrorLine($_)
  }
}

$Param = @{
  Function = $Public.BaseName
  Cmdlet   = '*'
  Alias    = '*'
  Verbose  = $false
}
Export-ModuleMember @Param
