function Step-SemanticVersion {
  <#
  .SYNOPSIS
    Increments a specific component of a Semanticver object (Major, Minor, Patch, PreReleaseIdentifier, BuildMetadata).
  .DESCRIPTION
    The `Step-SemanticVersion` function increments a chosen component of a `Semanticver` object, returning a new `Semanticver` object with the incremented version.
    It utilizes the `Semanticver::Increment()` static method to perform the version increment operation.

    You must provide a `Semanticver` object using the -Version parameter and specify which component to increment using the -Component parameter.

  .NOTES
    Currently, incrementing the PreReleaseIdentifier component will clear the PreRelease value as per the basic implementation in version 0.1.0 of the module.
    BuildMetadata component increment is a no-operation in version 0.1.0.

  .LINK
    https://semver.org/spec/v2.0.0.html

  .EXAMPLE
    # Increment the Minor version of a Semanticver object
    $semver = New-SemanticVersion -VersionString "1.2.3"
    $incrementedSemver = Step-SemanticVersion -Version $semver -Component Minor
    Write-Host "Incremented Version: $($incrementedSemver.ToString())"
    # Output will be a Semanticver object representing version 1.3.0

  .EXAMPLE
    # Increment the Patch version using pipeline input
    New-SemanticVersion -VersionString "2.5.0" | Step-SemanticVersion -Component Patch
    # Output will be a Semanticver object representing version 2.5.1

  .EXAMPLE
    # Increment the Major version
    $initialVersion = New-SemanticVersion -VersionString "0.8.7"
    $majorIncrementedVersion = Step-SemanticVersion -Version $initialVersion -Component Major
    Write-Host "Major Incremented Version: $($majorIncrementedVersion.ToString())"
    # Output: Major Incremented Version: 1.0.0
  #>
  [CmdletBinding()]
  [OutputType([Semanticver])]
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
    [ValidateNotNull()]
    [Semanticver]
    $Version,

    [Parameter(Mandatory = $true, Position = 1)]
    [ValidateNotNull()]
    [ValidateSet(
      "Major",
      "Minor",
      "Patch",
      "PreReleaseIdentifier",
      "BuildMetadata",
      IgnoreCase = $true
    )]
    [VersionComponent]
    $Component
  )

  process {
    try {
      # Call the static Increment method of the Semanticver class
      $incrementedVersion = [Semanticver]::Increment($Version, $Component)
      # Output the incremented Semanticver object
      Write-Output $incrementedVersion
    } catch {
      Write-Error -Exception $_ -ErrorCategory InvalidArgument -ErrorId "InvalidVersionComponentForIncrement" -TargetObject $Component
      throw $_
    }
  }
}