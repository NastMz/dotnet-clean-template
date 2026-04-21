# NastMz Clean Architecture Templates

A native .NET template pack for creating opinionated Clean Architecture projects from the command line with `dotnet new`.

## Installation

```powershell
dotnet new install NastMz.CleanArchitecture.Templates
```

Check that the templates are available:

```powershell
dotnet new list nast
```

## Available templates

| Template | Short name | Best for |
| --- | --- | --- |
| NastMz Clean Architecture | `nast-clean` | APIs that use Docker Compose for local infrastructure |
| NastMz Clean Architecture Aspire | `nast-clean-aspire` | APIs that use .NET Aspire for orchestration and service defaults |

## Create a project

Create a Docker Compose based project:

```powershell
dotnet new nast-clean -n MyCompany.MyApi
```

Create an Aspire based project:

```powershell
dotnet new nast-clean-aspire -n MyCompany.MyPlatform
```

The value passed to `-n` becomes the generated solution and namespace name. Infrastructure-friendly names, such as Docker Compose service names, are derived from it automatically.

## What gets created?

Both templates generate the same core Clean Architecture structure:

```text
src/
  Application/
  Domain/
  Infrastructure/
  SharedKernel/
  Web.Api/
tests/
  ArchitectureTests/
```

### `src/Application`

Contains use cases, command/query abstractions, handlers, validation, pipeline behaviors and application-level contracts.

### `src/Domain`

Contains entities, value/domain concepts, domain events and domain errors. This layer is isolated from infrastructure and web concerns.

### `src/Infrastructure`

Contains persistence, authentication, authorization, database configuration, time providers, domain event dispatching and external dependency implementations.

### `src/SharedKernel`

Contains shared primitives such as `Result`, `Error`, `Entity`, validation errors and domain event interfaces.

### `src/Web.Api`

Contains the ASP.NET Core API composition root, endpoints, middleware, exception handling, OpenAPI setup and HTTP-specific behavior.

### `tests/ArchitectureTests`

Contains architecture tests that protect dependency rules between layers.

## Docker Compose template

Use:

```powershell
dotnet new nast-clean -n MyCompany.MyApi
```

In addition to the core structure, this template includes Docker Compose assets for local infrastructure:

```text
docker-compose.yml
docker-compose.override.yml
docker-compose.dcproj
launchSettings.json
```

This is the simpler option when you want a regular ASP.NET Core API with local dependencies managed by Docker Compose.

## Aspire template

Use:

```powershell
dotnet new nast-clean-aspire -n MyCompany.MyPlatform
```

In addition to the core structure, this template includes:

```text
src/
  Aspire.AppHost/
  Aspire.ServiceDefaults/
```

`Aspire.AppHost` defines local orchestration for the application and its dependencies.

`Aspire.ServiceDefaults` centralizes service discovery, health checks, resilience and OpenTelemetry defaults.

This is the better option when you want an Aspire-based local development and orchestration experience.

## Generated repository files

Generated projects include repository hygiene and automation files:

```text
AGENTS.md
.editorconfig
.gitignore
.dockerignore
.github/dependabot.yml
.github/workflows/build.yml
```

`AGENTS.md` contains project guidance for AI coding agents and contributors. It is editor-agnostic and can be read by any tool or person working in the generated project.

## Common commands after generation

Move into the generated project folder:

```powershell
cd MyCompany.MyApi
```

Run architecture tests:

```powershell
dotnet test .\tests\ArchitectureTests\ArchitectureTests.csproj
```

Run the API project directly:

```powershell
dotnet run --project .\src\Web.Api\Web.Api.csproj
```

For the Docker Compose template, you can also use Docker Compose from the generated project root:

```powershell
docker compose up --build
```

For the Aspire template, run the AppHost:

```powershell
dotnet run --project .\src\Aspire.AppHost\Aspire.AppHost.csproj
```

## Uninstall

```powershell
dotnet new uninstall NastMz.CleanArchitecture.Templates
```