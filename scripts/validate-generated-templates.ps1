param(
    [string]$PackageVersion = "0.0.0-local",
    [string]$Configuration = "Release"
)

$ErrorActionPreference = "Stop"

$repoRoot = Split-Path -Parent $PSScriptRoot
$packageOutput = Join-Path $repoRoot "artifacts\packages"
$scratchRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("nastmz-template-validation-" + [System.Guid]::NewGuid().ToString("N"))
$cleanOutput = Join-Path $scratchRoot "clean"
$aspireOutput = Join-Path $scratchRoot "aspire"
$packagePath = Join-Path $packageOutput ("NastMz.CleanArchitecture.Templates.{0}.nupkg" -f $PackageVersion)

try {
    if (Test-Path $packageOutput) {
        Remove-Item -LiteralPath $packageOutput -Recurse -Force
    }

    New-Item -ItemType Directory -Path $packageOutput | Out-Null
    New-Item -ItemType Directory -Path $scratchRoot | Out-Null

    Push-Location $repoRoot

    dotnet restore .\NastMz.CleanArchitecture.Templates.csproj
    dotnet pack .\NastMz.CleanArchitecture.Templates.csproj `
        -c $Configuration `
        --no-restore `
        -o $packageOutput `
        -p:PackageVersion=$PackageVersion `
        -p:Version=$PackageVersion

    dotnet new uninstall NastMz.CleanArchitecture.Templates | Out-Null
    dotnet new install $packagePath

    dotnet new nast-clean -n Validation.Clean -o $cleanOutput
    dotnet new nast-clean-aspire -n Validation.Aspire -o $aspireOutput

    dotnet restore (Join-Path $cleanOutput "Validation.Clean.slnx")
    dotnet build (Join-Path $cleanOutput "src\Web.Api\Web.Api.csproj") --no-restore -c $Configuration
    dotnet test (Join-Path $cleanOutput "tests\ArchitectureTests\ArchitectureTests.csproj") --no-restore -c $Configuration

    dotnet restore (Join-Path $aspireOutput "Validation.Aspire.slnx")
    dotnet build (Join-Path $aspireOutput "src\Aspire.AppHost\Aspire.AppHost.csproj") --no-restore -c $Configuration
    dotnet test (Join-Path $aspireOutput "tests\ArchitectureTests\ArchitectureTests.csproj") --no-restore -c $Configuration
}
finally {
    Pop-Location
    dotnet new uninstall NastMz.CleanArchitecture.Templates | Out-Null

    if (Test-Path $scratchRoot) {
        Remove-Item -LiteralPath $scratchRoot -Recurse -Force
    }
}
