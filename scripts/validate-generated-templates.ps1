param(
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
    if (Test-Path $packageOutput) {
        Remove-Item -LiteralPath $packageOutput -Recurse -Force
    }

    New-Item -ItemType Directory -Path $packageOutput | Out-Null
    New-Item -ItemType Directory -Path $scratchRoot | Out-Null

    Push-Location $repoRoot

    Invoke-Dotnet restore .\NastMz.CleanArchitecture.Templates.csproj
    Invoke-Dotnet pack .\NastMz.CleanArchitecture.Templates.csproj `
        -c $Configuration `
        --no-restore `
        -o $packageOutput `
        "-p:PackageVersion=$PackageVersion" `
        "-p:Version=$PackageVersion"

    dotnet new uninstall NastMz.CleanArchitecture.Templates | Out-Null
    Invoke-Dotnet new install $packagePath

    Invoke-Dotnet new nast-clean -n Validation.Clean -o $cleanOutput
    Invoke-Dotnet new nast-clean-aspire -n Validation.Aspire -o $aspireOutput

    # Generated projects opt into Microsoft.Testing.Platform through their global.json,
    # which dotnet only picks up when it runs from inside the generated directory.
    Push-Location $cleanOutput
    try {
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
