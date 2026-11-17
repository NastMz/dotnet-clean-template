# Contributing

This repository ships a NuGet template pack and two source template roots:

- `clean-architecture`
- `aspire-template`

## Validate templates locally

Before creating a release, validate the generated projects locally with:

```powershell
.\scripts\validate-generated-templates.ps1
```

The script:

1. restores and packs the template pack locally;
2. installs the generated `.nupkg`;
3. creates both templates in a temporary directory;
4. restores the generated projects;
5. builds the main entry projects;
6. runs the generated architecture tests;
7. removes the temporary artifacts.

To validate the latest version already published on nuget.org instead of the local sources, run:

```powershell
.\scripts\validate-generated-templates.ps1 -Source Published
```

## CI

The repository includes `.github/workflows/ci.yml` to run this validation automatically on push and pull request.

The weekly scheduled run (and manual runs) also validate the latest published package, so newly disclosed vulnerabilities in what users install today fail CI even when `main` is already fixed.

## Releases

Do not create a release until local validation and CI are green.
