# NastMz Clean Architecture Templates

`NastMz.CleanArchitecture.Templates` is a native .NET template pack for creating opinionated Clean Architecture projects from the command line with `dotnet new`.

## What gets installed?

Installing the package registers two project templates in the .NET CLI:

| Template | Short name | Creates |
| --- | --- | --- |
| NastMz Clean Architecture | `nast-clean` | Clean Architecture API with Docker Compose assets |
| NastMz Clean Architecture Aspire | `nast-clean-aspire` | Clean Architecture API with .NET Aspire AppHost and ServiceDefaults |

## Install from NuGet

After the package is published:

```powershell
dotnet new install NastMz.CleanArchitecture.Templates
```

List the templates:

```powershell
dotnet new list nast
```

Uninstall the package:

```powershell
dotnet new uninstall NastMz.CleanArchitecture.Templates
```

## Create a project

Docker Compose variant:

```powershell
dotnet new nast-clean -n MyCompany.MyApi
```

Aspire variant:

```powershell
dotnet new nast-clean-aspire -n MyCompany.MyPlatform
```

The `-n` value replaces the baseline `CleanArchitecture` namespace/project name. Slug-based identifiers such as compose service names are also derived from the project name.

## Generated structure

Both templates generate the same core architecture:

```text
src/
  Application/       Use cases, CQRS abstractions, validation and behaviors
  Domain/            Entities, domain events and domain errors
  Infrastructure/    EF Core, authentication, authorization, time, persistence
  SharedKernel/      Result, Error, Entity and domain-event primitives
  Web.Api/           HTTP API endpoints, middleware and app composition
tests/
  ArchitectureTests/ Dependency boundary tests for the architecture
```

The Docker Compose template also includes:

```text
docker-compose.yml
docker-compose.override.yml
docker-compose.dcproj
launchSettings.json
```

The Aspire template also includes:

```text
src/
  Aspire.AppHost/          Aspire orchestration
  Aspire.ServiceDefaults/  OpenTelemetry, health checks, resilience and discovery defaults
```

## Generated project conventions

Generated projects include vendor-neutral agent instructions and repository hygiene files:

```text
AGENTS.md
.editorconfig
.gitignore
.dockerignore
.github/dependabot.yml
.github/workflows/build.yml
```

`AGENTS.md` is intentionally used instead of Cursor-specific `.cursorrules` so the generated projects are not tied to one editor or AI vendor.

## Validate locally

Install directly from the source folders while developing the templates:

```powershell
dotnet new install .\clean-architecture
dotnet new install .\aspire-template
```

Validate the distributable package locally:

```powershell
dotnet pack .\NastMz.CleanArchitecture.Templates.csproj -c Release -o .\artifacts\packages
dotnet new install .\artifacts\packages\NastMz.CleanArchitecture.Templates.1.0.0.nupkg
dotnet new nast-clean -n Contoso.Orders -o .\artifacts\samples\orders
dotnet new nast-clean-aspire -n Contoso.Platform -o .\artifacts\samples\platform
dotnet test .\artifacts\samples\orders\tests\ArchitectureTests\ArchitectureTests.csproj
dotnet test .\artifacts\samples\platform\tests\ArchitectureTests\ArchitectureTests.csproj
dotnet new uninstall NastMz.CleanArchitecture.Templates
```

Build, pack and test commands are useful feedback, but passing commands are not a substitute for checking that the generated project still satisfies the architecture and template requirements.

## Release and NuGet publishing

The root workflow `.github/workflows/release.yml` publishes the package when a version tag is pushed:

```powershell
git tag v1.0.0
git push origin v1.0.0
```

The workflow does three things:

1. Packs `NastMz.CleanArchitecture.Templates.csproj` with the version from the tag.
2. Publishes the `.nupkg` to NuGet.
3. Creates a GitHub Release and attaches the `.nupkg`.

### NuGet Trusted Publishing setup

The workflow uses NuGet Trusted Publishing instead of a long-lived `NUGET_API_KEY`.

Before the first release:

1. In nuget.org, create a Trusted Publishing policy for this GitHub repository.
2. Set the workflow file to `release.yml`.
3. Add a GitHub Actions secret named `NUGET_USER` with the nuget.org username/profile that owns the package.
4. Push a tag like `v1.0.0`.

If you cannot use Trusted Publishing, replace the `NuGet/login@v1` step with a `NUGET_API_KEY` secret and `dotnet nuget push --api-key ${{ secrets.NUGET_API_KEY }}`.

## Package contents

The pack project includes both template roots as package content and excludes generated outputs/caches such as:

```text
bin/
obj/
.vs/
.idea/
.git/
.containers/
```

Template dotfiles and `.github/` files are intentionally included so generated projects start with the same style, ignore, build and agent-instruction conventions.