# Claude Code Rules

## Local container builds

The Podman machine is arm64 native (Apple HV, no Rosetta). `podman build` without
`--platform` produces arm64 by default — no flag needed.

If you see this warning at the FROM step:
```
WARNING: image platform (linux/amd64) does not match the expected platform (linux/arm64)
```
the base image cache is contaminated with an amd64 pull. Fix it before building:
```bash
podman pull --platform linux/arm64 registry.redhat.io/ubi9/python-312:latest
```

Never add `--platform linux/amd64` to local build commands.

## CI

CI builds natively: amd64 on `ubuntu-24.04`, arm64 on `ubuntu-24.04-arm`. The manifest
job combines them into a multi-arch image at `ghcr.io/kpiwko/notebooklm-mcp`.
