function New-SemanticVersion {
  <#
  .SYNOPSIS
    Creates a new Semanticver object.
  .DESCRIPTION
    The `New-SemanticVersion` function creates a new `Semanticver` object.
    You can create a Semanticver object in two ways:

    1.  By providing a semantic version string using the -VersionString parameter. The function will parse the string and create the object.
    2.  By specifying individual version components (Major, Minor, Patch, PreRelease, Build) as parameters.

    This function provides a user-friendly way to instantiate Semanticver objects within PowerShell.

  .LINK
    https://semver.org/spec/v2.0.0.html

  .EXAMPLE
    # Create a Semanticver object from a version string
    New-SemanticVersion -VersionString "1.2.3-beta+build456"
    # Output will be a Semanticver object representing version 1.2.3-beta+build456

  .EXAMPLE
    # Create a Semanticver object by specifying individual components
    New-SemanticVersion -Major 1 -Minor 2 -Patch 3 -PreRelease "rc.1" -Build "sha256"
    # Output will be a Semanticver object representing version 1.2.3-rc.1+sha256

  .EXAMPLE
    # Create a basic Semanticver object with just major, minor, and patch versions
    New-SemanticVersion -Major 3 -Minor 0 -Patch 0
    # Output will be a Semanticver object representing version 3.0.0

  .EXAMPLE
    # Using pipeline input to create a Semanticver object (string input)
    "1.0.0" | New-SemanticVersion
    # Output will be a Semanticver object representing version 1.0.0
  #>
  [CmdletBinding(DefaultParameterSetName = 'StringInput')]
  [OutputType([Semanticver])]
  [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseShouldProcessForStateChangingFunctions', '')]
  param (
    [Parameter(ParameterSetName = 'StringInput', Mandatory = $true, Position = 0, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
    [Alias('Version', 'VersionString')]
    [string]
    $InputObject,

    [Parameter(ParameterSetName = 'ElementsInput', Mandatory = $true)]
    [ValidateRange(0, 2147483647)]
    [int]
    $Major,

    [Parameter(ParameterSetName = 'ElementsInput', Mandatory = $true)]
    [ValidateRange(0, 2147483647)]
    [int]
    $Minor,

    [Parameter(ParameterSetName = 'ElementsInput', Mandatory = $true)]
    [ValidateRange(0, 2147483647)]
    [int]
    $Patch,

    [Parameter(ParameterSetName = 'ElementsInput')]
    [string]
    $PreRelease,

    [Parameter(ParameterSetName = 'ElementsInput')]
    [string]
    $Build
  )

  begin {
  }

  process {
    switch ($PSCmdlet.ParameterSetName) {
      'StringInput' {
        try {
          # Parse Semanticver object from string input
          $semanticVersion = [Semanticver]::Parse($InputObject)
          Write-Output $semanticVersion
        } catch {
          Write-Error -Exception $_ -ErrorCategory InvalidArgument -ErrorId "InvalidSemVerString" -TargetObject $InputObject
          throw $_
        }
      }
      'ElementsInput' {
        # Create Semanticver object from individual components
        $semanticVersion = [Semanticver]::new()
        $semanticVersion.Major = $Major
        $semanticVersion.Minor = $Minor
        $semanticVersion.Patch = $Patch
        if ($PSBoundParameters.ContainsKey('PreRelease')) {
          $semanticVersion.PreRelease = $PreRelease
        }
        if ($PSBoundParameters.ContainsKey('Build')) {
          $semanticVersion.Build = $Build
        }
        Write-Output $semanticVersion
      }
    }
  }

  end {
  }
}