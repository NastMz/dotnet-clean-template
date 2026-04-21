# Template features

This document explains what is included in the generated projects and how the main architectural pieces work.

## High-level architecture

Both templates generate a Clean Architecture style solution with these projects:

```text
src/
  Domain/
  Application/
  Infrastructure/
  SharedKernel/
  Web.Api/
tests/
  ArchitectureTests/
```

The dependency direction is intentional:

```text
Web.Api -> Infrastructure -> Application -> Domain
                           -> SharedKernel
```

`Domain` stays independent from Application, Infrastructure and Web.Api. `Application` depends on Domain/SharedKernel contracts but not on Infrastructure or Web.Api. `Infrastructure` implements Application abstractions. `Web.Api` is the composition root.

The generated `ArchitectureTests` project uses NetArchTest and Shouldly to protect these rules.

## Domain model included

The template ships with a small Todo/User sample domain so the generated project is not empty and demonstrates the intended patterns.

### `User`

Located in `src/Domain/Users/User.cs`.

Represents an application user with:

- `Id`
- `Email`
- `FirstName`
- `LastName`
- `PasswordHash`

The Infrastructure layer configures a unique index on `Email`.

### `TodoItem`

Located in `src/Domain/Todos/TodoItem.cs`.

Represents a user-owned todo item with:

- `Id`
- `UserId`
- `Description`
- `DueDate`
- `Labels`
- `IsCompleted`
- `CreatedAt`
- `CompletedAt`
- `Priority`

The Infrastructure layer maps `TodoItem.UserId` as a relationship to `User` and stores dates using UTC-aware conversion.

### Domain events

Entities inherit from `SharedKernel.Entity`, which stores domain events in memory until they are dispatched.

Included events:

- `UserRegisteredDomainEvent`
- `TodoItemCreatedDomainEvent`
- `TodoItemCompletedDomainEvent`
- `TodoItemDeletedDomainEvent`

`ApplicationDbContext.SaveChangesAsync` persists changes first and then dispatches domain events through `IDomainEventsDispatcher`. That means handlers run after the database transaction has completed. This favors eventual consistency for side effects.

## SharedKernel primitives

`SharedKernel` contains the primitives used across the solution:

- `Entity`
- `IDomainEvent`
- `IDomainEventHandler<T>`
- `Result`
- `Result<T>`
- `Error`
- `ErrorType`
- `ValidationError`
- `IDateTimeProvider`

The application uses explicit `Result` objects instead of throwing exceptions for expected business failures. Web endpoints convert failed results to RFC-style Problem Details responses.

## CQRS without MediatR

This template intentionally does not use MediatR.

Instead, it provides small internal abstractions in `Application.Abstractions.Messaging`:

```csharp
public interface ICommand;
public interface ICommand<TResponse>;
public interface IQuery<TResponse>;
```

Handlers are plain interfaces:

```csharp
public interface ICommandHandler<in TCommand>
    where TCommand : ICommand
{
    Task<Result> Handle(TCommand command, CancellationToken cancellationToken);
}

public interface ICommandHandler<in TCommand, TResponse>
    where TCommand : ICommand<TResponse>
{
    Task<Result<TResponse>> Handle(TCommand command, CancellationToken cancellationToken);
}

public interface IQueryHandler<in TQuery, TResponse>
    where TQuery : IQuery<TResponse>
{
    Task<Result<TResponse>> Handle(TQuery query, CancellationToken cancellationToken);
}
```

Handlers are registered with Scrutor assembly scanning in `Application.DependencyInjection`.

### Why no MediatR?

The template keeps dispatch explicit. Endpoints inject the exact handler they need:

```csharp
ICommandHandler<RegisterUserCommand, Guid> handler
```

That means:

- no hidden mediator pipeline;
- no runtime request dispatch magic;
- fewer dependencies;
- easier debugging for people learning the architecture;
- decorator-based cross-cutting behavior is still available.

This is CQRS as an architectural style, not CQRS as a dependency on a specific library.

## Application behaviors

The Application layer wires cross-cutting behavior through decorators.

### Validation decorator

`ValidationDecorator` wraps command handlers.

It:

1. Finds all FluentValidation validators for the command.
2. Runs them before the handler.
3. Returns a `ValidationError` result if validation fails.
4. Calls the inner handler only when validation succeeds.

Validation is applied to commands, not queries.

### Logging decorator

`LoggingDecorator` wraps command and query handlers.

It logs:

- when commands/queries start;
- when they complete successfully;
- when they complete with an application error.

Logging calls are guarded with `logger.IsEnabled(...)` so generated projects stay compatible with analyzer rules such as CA1873 when warnings are treated as errors.

## Authentication

Authentication is implemented with JWT bearer tokens.

### Registration

The `users/register` endpoint creates a `RegisterUserCommand`.

The handler:

1. Checks whether the email already exists.
2. Hashes the password.
3. Creates a `User` entity.
4. Raises `UserRegisteredDomainEvent`.
5. Adds the user to the EF Core context.
6. Returns the new user id.

### Login

The `users/login` endpoint creates a `LoginUserCommand`.

The handler:

1. Looks up the user by email.
2. Verifies the submitted password against the stored hash.
3. Returns a JWT when credentials are valid.

### Password hashing

`PasswordHasher` uses PBKDF2:

- SHA-512
- 500,000 iterations
- 16-byte salt
- 32-byte hash
- fixed-time comparison for verification

Stored format:

```text
{HASH_HEX}-{SALT_HEX}
```

### JWT creation

`TokenProvider` creates JWTs with:

- subject claim from the user id;
- email claim from the user email;
- HMAC SHA-256 signing;
- issuer, audience, secret and expiration read from `Jwt` configuration.

Configuration shape:

```json
"Jwt": {
  "Secret": "...",
  "Issuer": "...",
  "Audience": "...",
  "ExpirationInMinutes": 60
}
```

### Current user access

Application handlers depend on `IUserContext` when they need the authenticated user id.

Infrastructure implements this through `HttpContext.User` and exposes `UserContext.UserId` to Application code without making Application depend on ASP.NET Core.

## Authorization and permissions

The template includes a permission-based authorization skeleton.

Pieces included:

- `HasPermissionAttribute`
- `PermissionRequirement`
- `PermissionAuthorizationPolicyProvider`
- `PermissionAuthorizationHandler`
- `PermissionProvider`

Endpoints can require permission policies through the endpoint extension:

```csharp
.HasPermission(Permissions.UsersAccess)
```

The included `PermissionProvider` is intentionally a stub. It returns an empty permission set and is meant to be replaced with your real permission lookup.

Important: the current authorization handler contains TODO comments and temporary behavior for authenticated users. Treat the permission provider/handler as a starting point, not a finished authorization model.

## API endpoint style

The template uses endpoint classes instead of controllers as the default style.

Each endpoint implements:

```csharp
public interface IEndpoint
{
    void MapEndpoint(IEndpointRouteBuilder app);
}
```

`Web.Api.Extensions.EndpointExtensions` scans the Web.Api assembly, registers all endpoint classes, and maps them during startup.

This gives you one file per endpoint while keeping ASP.NET Core Minimal API performance and routing style.

Included endpoint groups:

- Users
  - register
  - login
  - get by id
- Todos
  - create
  - get list
  - get by id
  - complete
  - update
  - delete
  - copy in the Docker Compose template

Endpoint handlers call Application command/query handlers and convert `Result` values to HTTP responses.

## Error handling

Expected failures are represented as `Result`/`Error` values.

`CustomResults.Problem` maps error types to HTTP responses:

| Error type | HTTP status |
| --- | --- |
| Validation | 400 |
| Problem | 400 |
| NotFound | 404 |
| Conflict | 409 |
| Failure / unexpected | 500 |

Unexpected exceptions are handled by `GlobalExceptionHandler`, logged and returned as Problem Details.

## Persistence

Persistence uses EF Core with PostgreSQL through Npgsql.

`ApplicationDbContext` exposes:

```csharp
DbSet<User> Users
DbSet<TodoItem> TodoItems
```

The Infrastructure layer:

- uses PostgreSQL;
- uses snake_case naming conventions;
- configures a default schema;
- stores EF migration history in that schema;
- applies entity configurations from the Infrastructure assembly;
- dispatches domain events after saving changes.

In development, `Web.Api` applies migrations automatically when the application starts.

## Observability and health

Both templates include:

- health checks for PostgreSQL;
- `/health` endpoint;
- request context logging middleware;
- OpenAPI document generation at `/openapi/v1.json`;
- Scalar API reference at `/scalar/v1`;
- JWT bearer security metadata in OpenAPI so Scalar can authenticate requests with login tokens;
- global exception handling.

The Docker Compose template additionally includes Serilog and Seq configuration.

The Aspire template additionally includes Aspire service defaults with:

- OpenTelemetry metrics;
- OpenTelemetry tracing;
- HTTP client resilience;
- service discovery;
- liveness endpoint mapping for development.

## Docker Compose template details

The `nast-clean` template includes Docker Compose assets for local development:

- `web-api`
- `postgres`
- `seq`

It maps the API and infrastructure dependencies through `docker-compose.yml` and `docker-compose.override.yml`.

Use this template when you want a straightforward local dependency setup with Docker Compose.

## Aspire template details

The `nast-clean-aspire` template includes:

- `Aspire.AppHost`
- `Aspire.ServiceDefaults`

`Aspire.AppHost` creates a PostgreSQL resource and wires the Web.Api project to it.

Use this template when you want the Aspire dashboard, orchestration model, service discovery, resilience and OpenTelemetry defaults.

## Tests included

The template includes architecture tests that assert:

- Domain does not depend on Application.
- Domain does not depend on Infrastructure.
- Domain does not depend on Web.Api.
- Application does not depend on Infrastructure.
- Application does not depend on Web.Api.
- Infrastructure does not depend on Web.Api.

Run them with:

```powershell
dotnet test .\tests\ArchitectureTests\ArchitectureTests.csproj
```

## What you are expected to replace

The template gives you a working starting point, not your final product.

You will usually replace or extend:

- sample Todo endpoints;
- sample User flows;
- permission lookup in `PermissionProvider`;
- JWT secrets and issuer/audience configuration;
- database connection strings;
- domain entities and use cases;
- integration and unit test coverage.

Do not remove architecture tests lightly. They are there to stop the structure from rotting while the application grows.
