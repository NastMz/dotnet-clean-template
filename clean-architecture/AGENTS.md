# AGENTS.md

## Project Rules

- Use modern C# and ASP.NET Core features where they improve clarity.
- Follow SOLID principles in class and interface design.
- Preserve Clean Architecture boundaries: Domain must not depend on Application, Infrastructure, or Web.Api.
- Implement dependency injection for loose coupling.
- Use primary constructors for dependency injection in services, handlers, decorators, and similar types.
- Use async/await for I/O-bound operations.
- Prefer record types for immutable data structures.
- Prefer explicit typing. Use `var` only when the type is obvious from the right-hand side.
- Make types `internal` and `sealed` by default unless extensibility is intentional.
- Prefer `Guid` for identifiers unless another identifier type is explicitly required.
- Use `is null` / `is not null` checks instead of `== null` / `!= null`.

## API Rules

- Prefer endpoint classes over controllers for this template style.
- Use minimal APIs only for simple endpoints or when explicitly chosen.
- Implement proper exception handling and structured logging.
- Use strongly typed configuration with the options pattern when configuration grows beyond trivial values.
- Implement authentication and authorization deliberately; do not bypass policies for convenience.
- Use Scalar/OpenAPI for API documentation.
- Use environment-specific configuration files.
- Use HTTPS and secure defaults.
- Validate input at the application boundary.

## Infrastructure Rules

- Use Entity Framework Core for relational persistence in the default template.
- Keep provider-specific infrastructure behind abstractions exposed by Application.
- Use health checks for external dependencies.
- Keep migrations and database configuration inside Infrastructure.

## Testing Rules

- Add unit tests for business logic.
- Add integration tests for API and infrastructure behavior when behavior crosses process or dependency boundaries.
- Keep architecture tests passing; they protect the dependency rules of the template.
- Build and test commands are useful feedback, but passing commands are not a substitute for checking requirements and architecture boundaries.
