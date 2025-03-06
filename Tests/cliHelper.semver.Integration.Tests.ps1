Describe "Integration tests: cliHelper.semver" {
  Context "Parse, Increment, and ToString Integration" {
    It "Parse, Increment Major, and ToString" {
      $initialVersionString = "1.2.3-alpha+build"
      $semver = [Semanticver]::Parse($initialVersionString)
      $incrementedSemver = [Semanticver]::Increment($semver, [VersionComponent]::Major)
      $incrementedVersionString = $incrementedSemver.ToString()
      $incrementedVersionString | Should -Be "2.0.0"
    }

    It "Parse, Increment Minor, and ToString" {
      $initialVersionString = "1.2.3-alpha+build"
      $semver = [Semanticver]::Parse($initialVersionString)
      $incrementedSemver = [Semanticver]::Increment($semver, [VersionComponent]::Minor)
      $incrementedVersionString = $incrementedSemver.ToString()
      $incrementedVersionString | Should -Be "1.3.0"
    }

    It "Parse, Increment Patch, and ToString" {
      $initialVersionString = "1.2.3-alpha+build"
      $semver = [Semanticver]::Parse($initialVersionString)
      $incrementedSemver = [Semanticver]::Increment($semver, [VersionComponent]::Patch)
      $incrementedVersionString = $incrementedSemver.ToString()
      $incrementedVersionString | Should -Be "1.2.4"
    }
  }

  Context "Parse, GetComponent, and CompareComponent Integration" {
    It "Parse, GetComponent Major, and CompareComponent Major - Lower" {
      $versionString1 = "1.2.3"
      $versionString2 = "2.0.0"
      $semver1 = [Semanticver]::Parse($versionString1)
      $semver2 = [Semanticver]::Parse($versionString2)
      $component1 = [Semanticver]::GetComponent($semver1, [VersionComponent]::Major)
      $component2 = [Semanticver]::GetComponent($semver2, [VersionComponent]::Major)
      $comparisonResult = [Semanticver]::CompareComponent($component1, $component2, [VersionComponent]::Major)
      $comparisonResult | Should -Be [PrecedenceComparisonResult]::Lower
    }

    It "Parse, GetComponent Patch, and CompareComponent Patch - Higher" {
      $versionString1 = "1.2.4"
      $versionString2 = "1.2.3"
      $semver1 = [Semanticver]::Parse($versionString1)
      $semver2 = [Semanticver]::Parse($versionString2)
      $component1 = [Semanticver]::GetComponent($semver1, [VersionComponent]::Patch)
      $component2 = [Semanticver]::GetComponent($semver2, [VersionComponent]::Patch)
      $comparisonResult = [Semanticver]::CompareComponent($component1, $component2, [VersionComponent]::Patch)
      $comparisonResult | Should -Be [PrecedenceComparisonResult]::Higher
    }
  }

  Context "Chained Increment Operations Integration" {
    It "Parse, Increment Major, Increment Minor, and ToString" {
      $initialVersionString = "1.2.3"
      $semver = [Semanticver]::Parse($initialVersionString)
      $semver = [Semanticver]::Increment($semver, [VersionComponent]::Major) # Increment Major first
      $semver = [Semanticver]::Increment($semver, [VersionComponent]::Minor) # Then increment Minor
      $incrementedVersionString = $semver.ToString()
      $incrementedVersionString | Should -Be "2.1.0" # Major increment resets Minor & Patch
    }

    It "Parse, Increment Patch Twice, and ToString" {
      $initialVersionString = "1.2.3"
      $semver = [Semanticver]::Parse($initialVersionString)
      $semver = [Semanticver]::Increment($semver, [VersionComponent]::Patch)
      $semver = [Semanticver]::Increment($semver, [VersionComponent]::Patch) # Increment Patch twice
      $incrementedVersionString = $semver.ToString()
      $incrementedVersionString | Should -Be "1.2.5"
    }
  }

  Context "Complex Scenario Integration" {
    It "Parse, Increment Minor, GetComponent Minor, CompareComponent Minor, and ToString" {
      $initialVersionString = "1.2.3-alpha"
      $semver = [Semanticver]::Parse($initialVersionString)
      $incrementedSemver = [Semanticver]::Increment($semver, [VersionComponent]::Minor) # Increment Minor
      $minorComponent = [Semanticver]::GetComponent($incrementedSemver, [VersionComponent]::Minor) # Get Minor component
      $minorComponent | Should -Be 3 # Verify Minor component is now 3

      $anotherSemver = [Semanticver]::Parse("1.4.0")
      $comparisonResult = [Semanticver]::CompareComponent($incrementedSemver, $anotherSemver, [VersionComponent]::Minor)
      $comparisonResult | Should -Be [PrecedenceComparisonResult]::Lower # Verify comparison is correct (1.3.0 vs 1.4.0)

      $finalVersionString = $incrementedSemver.ToString()
      $finalVersionString | Should -Be "1.3.0" # Verify final ToString is correct
    }
  }
}