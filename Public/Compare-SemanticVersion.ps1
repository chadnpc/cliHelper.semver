function Compare-SemanticVersion {
  <#
  .SYNOPSIS
    Compares two Semanticver objects to determine their precedence according to SemVer v2.0.0.
  .DESCRIPTION
     This function implements the full SemVer v2.0.0 precedence comparison logic.
     It uses Semanticver::CompareComponent() internally for each component in the correct order (Major, Minor, Patch, PreRelease).
     It returns a PrecedenceComparisonResult enum value indicating whether the ReferenceVersion is Lower, Equal, or Higher in precedence than the DifferenceVersion.
  .LINK
    https://semver.org/spec/v2.0.0.html
  .EXAMPLE
    $semver1 = New-SemanticVersion -VersionString "1.2.3-alpha"
    $semver2 = New-SemanticVersion -VersionString "1.2.3-beta"
    Compare-SemanticVersion -ReferenceVersion $semver1 -DifferenceVersion $semver2 # Output: Lower

    # Example showing higher precedence
    $semver3 = New-SemanticVersion -VersionString "2.0.0"
    $semver4 = New-SemanticVersion -VersionString "1.5.0"
    Compare-SemanticVersion -ReferenceVersion $semver3 -DifferenceVersion $semver4 # Output: Higher

    # Example showing equal precedence
    $semver5 = New-SemanticVersion -VersionString "1.2.3"
    $semver6 = New-SemanticVersion -VersionString "1.2.3"
    Compare-SemanticVersion -ReferenceVersion $semver5 -DifferenceVersion $semver6 # Output: Equal
  #>
  [CmdletBinding()][OutputType([PrecedenceComparisonResult])]
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
    [ValidateNotNull()]
    [Semanticver]
    $ReferenceVersion,

    [Parameter(Mandatory = $true, Position = 1)]
    [ValidateNotNull()]
    [Semanticver]
    $DifferenceVersion
  )

  process {
    # 1. Compare Major versions
    $majorComparison = [Semanticver]::CompareComponent($ReferenceVersion, $DifferenceVersion, [VersionComponent]::Major)
    if ($majorComparison -ne [PrecedenceComparisonResult]::Equal) {
      return $majorComparison
    }

    # 2. Compare Minor versions if Major versions are equal
    $minorComparison = [Semanticver]::CompareComponent($ReferenceVersion, $DifferenceVersion, [VersionComponent]::Minor)
    if ($minorComparison -ne [PrecedenceComparisonResult]::Equal) {
      return $minorComparison
    }

    # 3. Compare Patch versions if Major and Minor are equal
    $patchComparison = [Semanticver]::CompareComponent($ReferenceVersion, $DifferenceVersion, [VersionComponent]::Patch)
    if ($patchComparison -ne [PrecedenceComparisonResult]::Equal) {
      return $patchComparison
    }

    # 4. Compare Pre-release versions if Major, Minor, and Patch are equal
    #    Pre-release versions have lower precedence than normal versions.
    if (-not [string]::IsNullOrEmpty($ReferenceVersion.PreRelease) -and [string]::IsNullOrEmpty($DifferenceVersion.PreRelease)) {
      return [PrecedenceComparisonResult]::Lower # ReferenceVersion has pre-release, DifferenceVersion does not
    }
    if ([string]::IsNullOrEmpty($ReferenceVersion.PreRelease) -and -not [string]::IsNullOrEmpty($DifferenceVersion.PreRelease)) {
      return [PrecedenceComparisonResult]::Higher # ReferenceVersion does not have pre-release, DifferenceVersion does
    }
    if (-not [string]::IsNullOrEmpty($ReferenceVersion.PreRelease) -and -not [string]::IsNullOrEmpty($DifferenceVersion.PreRelease)) {
      # Both have pre-release, compare PreReleaseIdentifier component
      $preReleaseComparison = [Semanticver]::CompareComponent($ReferenceVersion, $DifferenceVersion, [VersionComponent]::PreReleaseIdentifier)
      if ($preReleaseComparison -ne [PrecedenceComparisonResult]::Equal) {
        return $preReleaseComparison
      }
    }

    # 5. Build metadata is ignored in precedence, so if all other components are equal, versions are equal in precedence.
    return [PrecedenceComparisonResult]::Equal
  }
}