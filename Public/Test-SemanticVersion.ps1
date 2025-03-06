function Test-SemanticVersion {
  <#
  .SYNOPSIS
    Checks if a given string is a valid semantic version according to SemVer v2.0.0.
  .DESCRIPTION
    The `Test-SemanticVersion` function validates whether an input string conforms to the Semantic Versioning 2.0.0 specification.
    It directly utilizes the `Semanticver::IsValid()` static method to perform the validation.

    The function takes a string as input via the -VersionString parameter and returns a boolean value:
    - $true if the input string is a valid semantic version.
    - $false if the input string is not a valid semantic version.

    This function is useful for:
    - Input validation in scripts that handle semantic versions.
    - Quickly checking if a string is a valid SemVer before attempting to parse it.

  .LINK
    https://semver.org/spec/v2.0.0.html
  .EXAMPLE
    Test-SemanticVersion -VersionString "1.2.3-alpha.1"
    # Output will be True if "1.2.3-alpha.1" is a valid semantic version string.

  .EXAMPLE
    Test-SemanticVersion -VersionString "invalid-version"
    # Output will be False because "invalid-version" is not a valid semantic version string.

  .EXAMPLE
    # Using pipeline input to test a version string
    "2.0.0+build.5" | Test-SemanticVersion
    # Output will be True for valid version string from pipeline.

  .EXAMPLE
    # Conditional logic based on version validity
    if (Test-SemanticVersion -VersionString $userInputVersion) {
      Write-Host "$userInputVersion is a valid Semantic Version."
      # Proceed with further processing of the valid version
    } else {
      Write-Warning "$userInputVersion is not a valid Semantic Version. Please check the format."
    }
  #>
  [CmdletBinding()]
  [OutputType([bool])]
  param (
    [Parameter(Mandatory = $true, ValueFromPipeline = $true, Position = 0)]
    [Alias('Version', 'VersionString')]
    [string]
    $InputObject
  )

  process {
    return [Semanticver]::IsValid($InputObject)
  }
}