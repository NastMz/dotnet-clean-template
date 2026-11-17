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

The generated application includes:

- a sample User/Todo domain;
- CQRS-style commands and queries without MediatR;
- command validation with FluentValidation decorators;
- command/query logging decorators;
- Result/Error primitives instead of exception-driven business flow;
- JWT bearer authentication;
- PBKDF2 password hashing;
- permission-based authorization scaffolding;
- EF Core + PostgreSQL persistence;
- domain events dispatched from EF Core save changes;
- endpoint classes over Minimal APIs;
- Problem Details error responses;
- Scalar/OpenAPI API reference;
- health checks;
- architecture tests.

For the full breakdown, see [Template features](https://github.com/NastMz/dotnet-clean-template/blob/main/docs/features.md).

## Add a feature

The pack also includes the `nast-feature` item template, which scaffolds one use case: the message, its handler, a validator (commands only), and a Minimal API endpoint. Run it from the root of a generated solution (the folder that contains `src/`):

```powershell
# Command without a return value -> POST, 204 No Content on success
dotnet new nast-feature -n Archive --module Todos

# Command that returns a value -> POST, 200 OK
dotnet new nast-feature -n Duplicate --module Todos --response Guid

# Query with a generated GetSummaryResponse class -> GET
dotnet new nast-feature -n GetSummary --module Todos --kind query

# Query with an existing response type
dotnet new nast-feature -n GetProfile --module Users --kind query --response UserResponse
```

| Option | Description |
| --- | --- |
| `-n` | Use case name. Files and namespaces are derived from it, for example `ArchiveCommand` in `Application.Todos.Archive`. |
| `--module` | Required. Feature folder, for example `Todos`. |
| `--kind` | `command` (default) or `query`. |
| `--response` | Response type. Optional for commands; for queries, omit it to generate a `<Name>Response` class. Add the `using` for types from other namespaces. |

Nothing has to be registered by hand: Scrutor picks up the handler and validator, the validation, caching and logging decorators wrap it, and the endpoint is discovered through `IEndpoint`. The generated handler returns a `NotImplemented` failure until you write the use case. The route (`<module>/{id:guid}/<name>`, in kebab case) and the OpenAPI tag (the module name) are starting points to adjust.


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

It includes local services for the API, PostgreSQL and Seq.

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

`Aspire.AppHost` defines local orchestration for the application and PostgreSQL.

`Aspire.ServiceDefaults` centralizes service discovery, health checks, resilience and OpenTelemetry defaults.

## Generated repository files

Generated projects include repository hygiene and automation files:

```text
AGENTS.md
.editorconfig
.gitignore
.dockerignore
global.json
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
dotnet test --project .\tests\ArchitectureTests\ArchitectureTests.csproj
```

Generated projects use xUnit v3 on Microsoft.Testing.Platform, enabled through the generated `global.json`. Run `dotnet test` from the project root, and add `--coverlet` to collect code coverage.

Run the API project directly:

```powershell
dotnet run --project .\src\Web.Api\Web.Api.csproj
```

In Development, the OpenAPI document is exposed at `/openapi/v1.json` and the Scalar API reference is available at `/scalar/v1`.
Scalar is configured with the template's JWT bearer security scheme, so you can authenticate requests in the API reference with the token returned by the login endpoint.

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
