param(
    # Local packs the template pack from this repository; Published installs the latest stable version from nuget.org.
    [ValidateSet("Local", "Published")]
    [string]$Source = "Local",
    [string]$PackageVersion = "0.0.0-local",
    [string]$Configuration = "Release"
)

$ErrorActionPreference = "Stop"

# Native commands do not honor $ErrorActionPreference, so check every dotnet exit code explicitly.
function Invoke-Dotnet {
    dotnet @args

    if ($LASTEXITCODE -ne 0) {
        throw "dotnet $($args -join ' ') failed with exit code $LASTEXITCODE."
    }
}

$repoRoot = Split-Path -Parent $PSScriptRoot
$packageOutput = Join-Path $repoRoot "artifacts\packages"
$scratchRoot = Join-Path ([System.IO.Path]::GetTempPath()) ("nastmz-template-validation-" + [System.Guid]::NewGuid().ToString("N"))
$cleanOutput = Join-Path $scratchRoot "clean"
$aspireOutput = Join-Path $scratchRoot "aspire"
$packagePath = Join-Path $packageOutput ("NastMz.CleanArchitecture.Templates.{0}.nupkg" -f $PackageVersion)

try {
    New-Item -ItemType Directory -Path $scratchRoot | Out-Null

    Push-Location $repoRoot

    dotnet new uninstall NastMz.CleanArchitecture.Templates | Out-Null

    if ($Source -eq "Local") {
        if (Test-Path $packageOutput) {
            Remove-Item -LiteralPath $packageOutput -Recurse -Force
        }

        New-Item -ItemType Directory -Path $packageOutput | Out-Null

        Invoke-Dotnet restore .\NastMz.CleanArchitecture.Templates.csproj
        Invoke-Dotnet pack .\NastMz.CleanArchitecture.Templates.csproj `
            -c $Configuration `
            --no-restore `
            -o $packageOutput `
            "-p:PackageVersion=$PackageVersion" `
            "-p:Version=$PackageVersion"

        Invoke-Dotnet new install $packagePath
    }
    else {
        # Without an explicit version, dotnet new install resolves the latest stable version.
        Invoke-Dotnet new install NastMz.CleanArchitecture.Templates --add-source https://api.nuget.org/v3/index.json
    }

    Invoke-Dotnet new nast-clean -n Validation.Clean -o $cleanOutput
    Invoke-Dotnet new nast-clean-aspire -n Validation.Aspire -o $aspireOutput

    # Generated projects opt into Microsoft.Testing.Platform through their global.json,
    # which dotnet only picks up when it runs from inside the generated directory.
    Push-Location $cleanOutput
    try {
        # Exercise every nast-feature variant so the generated slices are compiled and checked by the architecture tests.
        Invoke-Dotnet new nast-feature -n Archive --module Todos
        Invoke-Dotnet new nast-feature -n Duplicate --module Todos --response Guid
        Invoke-Dotnet new nast-feature -n GetSummary --module Todos --kind query
        Invoke-Dotnet new nast-feature -n GetProfile --module UserProfiles --kind query --response "List<string>"

        Invoke-Dotnet restore "Validation.Clean.slnx"
        Invoke-Dotnet build (Join-Path "src" "Web.Api" "Web.Api.csproj") --no-restore -c $Configuration
        Invoke-Dotnet test --project (Join-Path "tests" "ArchitectureTests" "ArchitectureTests.csproj") --no-restore -c $Configuration
    }
    finally {
        Pop-Location
    }

    Push-Location $aspireOutput
    try {
        Invoke-Dotnet restore "Validation.Aspire.slnx"
        Invoke-Dotnet build (Join-Path "src" "Aspire.AppHost" "Aspire.AppHost.csproj") --no-restore -c $Configuration
        Invoke-Dotnet test --project (Join-Path "tests" "ArchitectureTests" "ArchitectureTests.csproj") --no-restore -c $Configuration
    }
    finally {
        Pop-Location
    }
}
finally {
    Pop-Location
    dotnet new uninstall NastMz.CleanArchitecture.Templates | Out-Null

    if (Test-Path $scratchRoot) {
        Remove-Item -LiteralPath $scratchRoot -Recurse -Force
    }
}
