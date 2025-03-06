@{
  ModuleName    = 'cliHelper.semver'
  ModuleVersion = '0.1.0'
  ReleaseNotes  = '# Release Notes

- Version_0.1.0
  - Initial release of cliHelper.semver module.
  - Implements `Semanticver` PowerShell class for Semantic Versioning.
  - Includes static methods:
    - `Parse`: Parses a string into a `Semanticver` object.
    - `IsValid`: Checks if a string is a valid SemVer string.
    - `Increment`: Increments a specified version component (Major, Minor, Patch, PreReleaseIdentifier, BuildMetadata).
    - `GetComponent`: Gets the value of a specified version component.
    - `CompareComponent`: Compares a specified version component between two `Semanticver` objects.
  - Basic feature and integration Pester tests included.
  - Enums `VersionComponent` and `PrecedenceComparisonResult` are defined for type-safe version component handling.
  - No functions are exported in this version, module is class-based only.
  - Core SemVer v2.0.0 specification compliance for parsing and basic operations.
  - Initial implementation of increment operations (PreReleaseIdentifier and BuildMetadata increment are basic in this version).
  - String-based comparison for PreReleaseIdentifier in `CompareComponent`.
  - BuildMetadata is not considered in version precedence comparisons.
  - Basic error handling for invalid SemVer strings and unsupported operations.
  - Type accelerators registered for `Semanticver`, `VersionComponent`, and `PrecedenceComparisonResult`.
'
  # Localized strings for the module
  Strings       = @{
    InvalidSemVerString                         = 'Invalid Semantic Version string: ''{0}'''
    UnsupportedVersionComponentIncrement        = 'Unsupported VersionComponent for Increment: ''{0}'''
    UnsupportedVersionComponentGetComponent     = 'Unsupported VersionComponent for GetComponent: ''{0}'''
    UnsupportedVersionComponentCompareComponent = 'Unsupported VersionComponent for CompareComponent: ''{0}'''
    PreReleaseIncrementBasicNote                = 'Note: PreReleaseIdentifier increment in version 0.1.0 is a basic implementation that clears the Pre-release. More sophisticated logic will be added in future versions.'
    BuildMetadataIncrementBasicNote             = 'Note: BuildMetadata increment in version 0.1.0 is a no-operation as per SemVer specification. Custom logic for BuildMetadata increment may be added in future versions if needed.'
  }
}