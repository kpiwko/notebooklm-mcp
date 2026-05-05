# Claude Code Rules

## Local container builds

Build for your native platform — do not force `--platform`:

```bash
podman build -t localhost/notebooklm-mcp:dev .
```

Podman and Docker default to the host's native architecture. Forcing a non-native
platform (e.g. `--platform linux/amd64` on arm64) runs under emulation and is slower
and can cause build failures.

If you see a warning like:
```
WARNING: image platform (linux/amd64) does not match the expected platform (linux/arm64)
```
the base image is stale in the local cache. Refresh it before building:
```bash
podman pull registry.redhat.io/ubi9/python-312:latest
```

## CI

CI builds on native runners for each architecture and combines them into a multi-arch
manifest:
- `ubuntu-24.04` → amd64
- `ubuntu-24.04-arm` → arm64

The published image at `ghcr.io/kpiwko/notebooklm-mcp` supports both architectures.
