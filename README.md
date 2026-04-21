# NastMz Clean Architecture Templates

This repository packages two `dotnet new` templates:

- `nast-clean`
- `nast-clean-aspire`

## Install locally

Install directly from the source folders:

```powershell
dotnet new install .\clean-architecture
dotnet new install .\aspire-template
```

If you want to validate the distributable package locally, pack the repository root project and install the generated `.nupkg`:

```powershell
dotnet pack .\NastMz.CleanArchitecture.Templates.csproj -o .\artifacts\packages
dotnet new install .\artifacts\packages\NastMz.CleanArchitecture.Templates.1.0.0.nupkg
```

## Create a project

```powershell
dotnet new nast-clean -n MyApi
dotnet new nast-clean-aspire -n MyAspireApi
```

## Notes

- The pack project excludes generated outputs and caches such as `bin/`, `obj/`, `.vs/`, `.idea/`, `.git/`, and `.containers/`.
- Template dotfiles such as `.editorconfig`, `.gitignore`, `.dockerignore`, `.cursorrules`, and `.github/` are intentionally included in the package and generated projects.
- The local package flow above is the same one used for validation: `dotnet pack`, `dotnet new install <nupkg>`, `dotnet new list`, and sample generation with `dotnet new`.
- Build and pack commands are only quick feedback checks; they are not the definition of done for template compliance.
