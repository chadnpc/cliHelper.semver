function ConvertTo-SemanticVersion {
  <#
  .SYNOPSIS
    Converts various input types (primarily strings) to a Semanticver object.
    This function is designed to handle pipeline input gracefully and offers a way to create Semanticver objects from strings.
  .DESCRIPTION
    The `ConvertTo-SemanticVersion` function takes an input object, which is expected to be a string representing a semantic version, and attempts to convert it into a `Semanticver` object.
    It utilizes the `Semanticver::Parse()` static method for the conversion. If the input string is a valid semantic version, a `Semanticver` object is returned.
    If the input is not a valid semantic version string, the function will throw an error.

    This function is useful for:
    - Processing semantic version strings from pipeline input.
    - Converting hardcoded semantic version strings into `Semanticver` objects for further manipulation within PowerShell scripts.

  .NOTES
    Currently, this function primarily supports string inputs that conform to the Semantic Versioning 2.0.0 specification.
    TODO: In Future versions I'll include support for converting from other version formats or object types if necessary.

  .LINK
    https://semver.org/spec/v2.0.0.html

  .EXAMPLE
    "1.2.3-rc.1+build.123" | ConvertTo-SemanticVersion
    # Returns a Semanticver object representing version 1.2.3-rc.1+build.123

  .EXAMPLE
    ConvertTo-SemanticVersion -InputObject "2.0.0+meta-info"
    # Returns a Semanticver object representing version 2.0.0+meta-info

  .EXAMPLE
    ConvertTo-SemanticVersion -InputObject "invalid-version-string"
    # Throws an exception because "invalid-version-string" is not a valid semantic version.
  #>
  [CmdletBinding(DefaultParameterSetName = 'StringInput')]
  [OutputType([Semanticver])]
  param (
    [Parameter(ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, Mandatory = $true, Position = 0, ParameterSetName = 'StringInput')]
    [Alias('VersionString', 'Version')]
    [string]
    $InputObject
  )
  process {
    try {
      # Attempt to parse the input object as a semantic version string
      $semanticVersion = [Semanticver]::Parse($InputObject)
      # Output the parsed Semanticver object
      Write-Output $semanticVersion
    } catch {
      Write-Error -Exception $_ -ErrorCategory InvalidArgument -ErrorId "InvalidSemVerString" -TargetObject $InputObject
      throw $_
    }
  }
}