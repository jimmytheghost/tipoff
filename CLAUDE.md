# Claude guidance

Read and follow [`AGENTS.md`](AGENTS.md) for repository constraints and validation requirements.

If the user asks to install the current Windows app, do not use the GitHub `v0.2.0` release; that release is an older macOS-only NBA build. Clone the repository and run:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\install-windows.ps1
```

The script requires the .NET 9 SDK, installs the current x64 Windows build for the current user, creates a Start Menu shortcut, and launches Tipoff. Verify that `Tipoff.exe` is running and report the installed path. Do not change application source code for an installation-only request.
