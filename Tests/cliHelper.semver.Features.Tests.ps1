Describe "Feature tests: cliHelper.semver" {
  Context "Parse and IsValid" {
    It "Parse valid SemVer strings" {
      $validVersions = @(
        "1.2.3",
        "1.2.3-alpha",
        "1.2.3+build123",
        "1.2.3-alpha.1+build123",
        "0.1.0",
        "10.20.30",
        "1.1.2-prerelease+meta",
        "1.0.0-rc.1+build.1",
        "1.0.0-SNAPSHOT-05-26-1967-1000"
      )
      foreach ($versionString in $validVersions) {
        $semver = [Semanticver]::Parse($versionString)
        $semver | Should BeOfType [Semanticver]
        [Semanticver]::IsValid($versionString) | Should BeTrue
      }
    }

    It "Parse invalid SemVer strings should throw" {
      $invalidVersions = @(
        "1.2",
        "1.2.3.4",
        "1.2.3-",
        "1.2.3+",
        "1.2.3-alpha+",
        "1.2.3+build-",
        "v1.2.3",
        "1.02.3",
        "1.2.-SNAPSHOT",
        "1.2.3-alpha_beta",
        "1.2.3+build_meta"
      )
      foreach ($versionString in $invalidVersions) {
        { [Semanticver]::Parse($versionString) } | Should Throw -Message "Invalid SemVer string: '$versionString'"
        [Semanticver]::IsValid($versionString) | Should BeFalse
      }
    }

    It "IsValid returns true for valid SemVer strings" {
      $validVersions = @(
        "1.2.3",
        "1.2.3-alpha",
        "1.2.3+build123"
      )
      foreach ($versionString in $validVersions) {
        [Semanticver]::IsValid($versionString) | Should BeTrue
      }
    }

    It "IsValid returns false for invalid SemVer strings" {
      $invalidVersions = @(
        "1.2",
        "1.2.3.4",
        "v1.2.3"
      )
      foreach ($versionString in $invalidVersions) {
        [Semanticver]::IsValid($versionString) | Should BeFalse
      }
    }
  }

  Context "ToString" {
    It "ToString returns correct SemVer string" {
      $semver = [Semanticver]::Parse("1.2.3-alpha.1+build.456")
      $semver.ToString() | Should -Be "1.2.3-alpha.1+build.456"

      $semverNoPreRelease = [Semanticver]::Parse("1.2.3+build.456")
      $semverNoPreRelease.ToString() | Should -Be "1.2.3+build.456"

      $semverNoBuild = [Semanticver]::Parse("1.2.3-alpha.1")
      $semverNoBuild.ToString() | Should -Be "1.2.3-alpha.1"

      $semverBasic = [Semanticver]::Parse("1.2.3")
      $semverBasic.ToString() | Should -Be "1.2.3"
    }
  }

  Context "Increment" {
    It "Increment Major version" {
      $semver = [Semanticver]::Parse("1.2.3")
      $incremented = [Semanticver]::Increment($semver, [VersionComponent]::Major)
      $incremented.ToString() | Should -Be "2.0.0"
    }

    It "Increment Minor version" {
      $semver = [Semanticver]::Parse("1.2.3")
      $incremented = [Semanticver]::Increment($semver, [VersionComponent]::Minor)
      $incremented.ToString() | Should -Be "1.3.0"
    }

    It "Increment Patch version" {
      $semver = [Semanticver]::Parse("1.2.3")
      $incremented = [Semanticver]::Increment($semver, [VersionComponent]::Patch)
      $incremented.ToString() | Should -Be "1.2.4"
    }

    It "Increment PreRelease version (clears prerelease for now)" {
      $semver = [Semanticver]::Parse("1.2.3-alpha")
      $incremented = [Semanticver]::Increment($semver, [VersionComponent]::PreReleaseIdentifier)
      $incremented.ToString() | Should -Be "1.2.3" # Current logic clears prerelease
    }

    It "Increment BuildMetadata version (no-op for now)" {
      $semver = [Semanticver]::Parse("1.2.3+build")
      $incremented = [Semanticver]::Increment($semver, [VersionComponent]::BuildMetadata)
      $incremented.ToString() | Should -Be "1.2.3+build" # Current logic is no-op
    }

    It "Increment with invalid VersionComponent should throw" {
      $semver = [Semanticver]::Parse("1.2.3")
      { [Semanticver]::Increment($semver, "InvalidComponent") } | Should Throw -Message "Unsupported VersionComponent for Increment: 'InvalidComponent'"
    }
  }

  Context "GetComponent" {
    It "GetComponent Major" {
      $semver = [Semanticver]::Parse("1.2.3-alpha+build")
      [Semanticver]::GetComponent($semver, [VersionComponent]::Major) | Should -Be 1
    }

    It "GetComponent Minor" {
      $semver = [Semanticver]::Parse("1.2.3-alpha+build")
      [Semanticver]::GetComponent($semver, [VersionComponent]::Minor) | Should -Be 2
    }

    It "GetComponent Patch" {
      $semver = [Semanticver]::Parse("1.2.3-alpha+build")
      [Semanticver]::GetComponent($semver, [VersionComponent]::Patch) | Should -Be 3
    }

    It "GetComponent PreReleaseIdentifier" {
      $semver = [Semanticver]::Parse("1.2.3-alpha+build")
      [Semanticver]::GetComponent($semver, [VersionComponent]::PreReleaseIdentifier) | Should -Be "alpha"
    }

    It "GetComponent BuildMetadata" {
      $semver = [Semanticver]::Parse("1.2.3-alpha+build")
      [Semanticver]::GetComponent($semver, [VersionComponent]::BuildMetadata) | Should -Be "build"
    }

    It "GetComponent with invalid VersionComponent should throw" {
      $semver = [Semanticver]::Parse("1.2.3")
      { [Semanticver]::GetComponent($semver, "InvalidComponent") } | Should Throw -Message "Unsupported VersionComponent for GetComponent: 'InvalidComponent'"
    }
  }

  Context "CompareComponent" {
    It "CompareComponent Major - Lower" {
      $semver1 = [Semanticver]::Parse("1.2.3")
      $semver2 = [Semanticver]::Parse("2.0.0")
      [Semanticver]::CompareComponent($semver1, $semver2, [VersionComponent]::Major) | Should -Be [PrecedenceComparisonResult]::Lower
    }

    It "CompareComponent Major - Higher" {
      $semver1 = [Semanticver]::Parse("2.0.0")
      $semver2 = [Semanticver]::Parse("1.2.3")
      [Semanticver]::CompareComponent($semver1, $semver2, [VersionComponent]::Major) | Should -Be [PrecedenceComparisonResult]::Higher
    }

    It "CompareComponent Major - Equal" {
      $semver1 = [Semanticver]::Parse("1.2.3")
      $semver2 = [Semanticver]::Parse("1.5.6") # Major is same for this test
      [Semanticver]::CompareComponent($semver1, $semver2, [VersionComponent]::Major) | Should -Be [PrecedenceComparisonResult]::Equal
    }

    It "CompareComponent Minor - Lower" {
      $semver1 = [Semanticver]::Parse("1.2.3")
      $semver2 = [Semanticver]::Parse("1.3.0")
      [Semanticver]::CompareComponent($semver1, $semver2, [VersionComponent]::Minor) | Should -Be [PrecedenceComparisonResult]::Lower
    }

    It "CompareComponent Minor - Higher" {
      $semver1 = [Semanticver]::Parse("1.3.0")
      $semver2 = [Semanticver]::Parse("1.2.3")
      [Semanticver]::CompareComponent($semver1, $semver2, [VersionComponent]::Minor) | Should -Be [PrecedenceComparisonResult]::Higher
    }

    It "CompareComponent Minor - Equal" {
      $semver1 = [Semanticver]::Parse("1.2.3")
      $semver2 = [Semanticver]::Parse("1.2.5") # Minor is same for this test
      [Semanticver]::CompareComponent($semver1, $semver2, [VersionComponent]::Minor) | Should -Be [PrecedenceComparisonResult]::Equal
    }

    It "CompareComponent Patch - Lower" {
      $semver1 = [Semanticver]::Parse("1.2.3")
      $semver2 = [Semanticver]::Parse("1.2.4")
      [Semanticver]::CompareComponent($semver1, $semver2, [VersionComponent]::Patch) | Should -Be [PrecedenceComparisonResult]::Lower
    }

    It "CompareComponent Patch - Higher" {
      $semver1 = [Semanticver]::Parse("1.2.4")
      $semver2 = [Semanticver]::Parse("1.2.3")
      [Semanticver]::CompareComponent($semver1, $semver2, [VersionComponent]::Patch) | Should -Be [PrecedenceComparisonResult]::Higher
    }

    It "CompareComponent Patch - Equal" {
      $semver1 = [Semanticver]::Parse("1.2.3")
      $semver2 = [Semanticver]::Parse("1.2.3-alpha") # Patch is same for this test
      [Semanticver]::CompareComponent($semver1, $semver2, [VersionComponent]::Patch) | Should -Be [PrecedenceComparisonResult]::Equal
    }

    It "CompareComponent PreReleaseIdentifier - Lower (string compare)" {
      $semver1 = [Semanticver]::Parse("1.2.3-alpha")
      $semver2 = [Semanticver]::Parse("1.2.3-beta")
      [Semanticver]::CompareComponent($semver1, $semver2, [VersionComponent]::PreReleaseIdentifier) | Should -Be [PrecedenceComparisonResult]::Lower
    }

    It "CompareComponent PreReleaseIdentifier - Higher (string compare)" {
      $semver1 = [Semanticver]::Parse("1.2.3-beta")
      $semver2 = [Semanticver]::Parse("1.2.3-alpha")
      [Semanticver]::CompareComponent($semver1, $semver2, [VersionComponent]::PreReleaseIdentifier) | Should -Be [PrecedenceComparisonResult]::Higher
    }

    It "CompareComponent PreReleaseIdentifier - Equal" {
      $semver1 = [Semanticver]::Parse("1.2.3-alpha")
      $semver2 = [Semanticver]::Parse("1.2.3-alpha+build") # PreRelease is same for this test
      [Semanticver]::CompareComponent($semver1, $semver2, [VersionComponent]::PreReleaseIdentifier) | Should -Be [PrecedenceComparisonResult]::Equal
    }

    It "CompareComponent BuildMetadata - Always Equal" {
      $semver1 = [Semanticver]::Parse("1.2.3+build1")
      $semver2 = [Semanticver]::Parse("1.2.3+build2")
      [Semanticver]::CompareComponent($semver1, $semver2, [VersionComponent]::BuildMetadata) | Should -Be [PrecedenceComparisonResult]::Equal
    }

    It "CompareComponent with invalid VersionComponent should throw" {
      $semver1 = [Semanticver]::Parse("1.2.3")
      $semver2 = [Semanticver]::Parse("1.2.4")
      { [Semanticver]::CompareComponent($semver1, $semver2, "InvalidComponent") } | Should Throw -Message "Unsupported VersionComponent for CompareComponent: 'InvalidComponent'"
    }
  }
}