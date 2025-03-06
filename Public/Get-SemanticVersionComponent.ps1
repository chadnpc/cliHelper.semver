function Get-SemanticVersionComponent {
  <#
  .SYNOPSIS
    Retrieves a specific component (Major, Minor, Patch, PreReleaseIdentifier, BuildMetadata) from a Semanticver object.
  .DESCRIPTION
    The `Get-SemanticVersionComponent` function allows you to extract a specific part of a Semantic Version from a `Semanticver` object.
    You can specify which component you want to retrieve using the -Component parameter.
    The function internally calls the `Semanticver::GetComponent()` static method to perform the component retrieval.

    Valid components you can retrieve are:
    - Major
    - Minor
    - Patch
    - PreReleaseIdentifier
    - BuildMetadata

  .LINK
    https://semver.org/spec/v2.0.0.html
  .EXAMPLE
    $semver = New-SemanticVersion -VersionString "1.2.3-alpha.1+build.456"
    Get-SemanticVersionComponent -Version $semver -Component PreReleaseIdentifier
    # Output: alpha.1

  .EXAMPLE
    $semver = ConvertTo-SemanticVersion -InputObject "2.0.0+meta"
    Get-SemanticVersionComponent -Version $semver -Component Major
    # Output: 2

  .EXAMPLE
    # Get the Patch version from a Semanticver object in a variable
    $myVersion = New-SemanticVersion -VersionString "1.5.7"
    $patchVersion = Get-SemanticVersionComponent -Version $myVersion -Component Patch
    Write-Host "The Patch version is: $patchVersion"
    # Output: The Patch version is: 7
  #>
  [CmdletBinding()]
  [OutputType([object])] # GetComponent can return different types (int or string)
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
    [ValidateNotNull()]
    [Semanticver]
    $Version,

    [Parameter(Mandatory = $true, Position = 1)]
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
      # Call the static GetComponent method of the Semanticver class
      $componentValue = [Semanticver]::GetComponent($Version, $Component)
      # Output the retrieved component value
      Write-Output $componentValue
    } catch {
      # Catch any exceptions from Semanticver::GetComponent (e.g., invalid component)
      Write-Error -Exception $_ -ErrorCategory InvalidArgument -ErrorId "InvalidVersionComponent" -TargetObject $Component
      throw $_
    }
  }
}