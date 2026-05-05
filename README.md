# notebooklm-mcp

NotebookLM MCP server container. Runs [`notebooklm-mcp-cli`](https://pypi.org/project/notebooklm-mcp-cli/)
as an HTTP MCP server with a browser-based auth interface via noVNC.

## Ports

| Port | Purpose |
|------|---------|
| 17200 | MCP HTTP endpoint (`/mcp`) |
| 17201 | noVNC web interface (auth only) |

## First-run auth

NotebookLM has no public API. Auth requires a one-time interactive Google login
inside the container's virtual browser.

```bash
# 1. Start the container
podman run -d --name notebooklm-mcp \
  -p 17200:17200 \
  -p 17201:6080 \
  -v "${XDG_CONFIG_HOME:-$HOME/.config}/notebooklm-mcp-cli:/root/.config/notebooklm-mcp-cli" \
  ghcr.io/kpiwko/notebooklm-mcp:latest

# 2. Open the VNC interface in your browser
open http://localhost:17201/vnc.html

# 3. In a second terminal, start the login flow
podman exec -it notebooklm-mcp nlm login
# Chrome opens in the VNC window — log into Google NotebookLM

# 4. Verify the MCP endpoint is reachable
curl -s http://localhost:17200/mcp \
  -H "Accept: application/json, text/event-stream" \
  -H "Content-Type: application/json" \
  --max-time 5
```

Credentials are saved to `~/.config/notebooklm-mcp-cli/` on the host and survive container restarts.

## Cookie refresh

Google session cookies expire every few weeks. When you see auth errors, repeat the login:

```bash
open http://localhost:17201/vnc.html
podman exec -it notebooklm-mcp nlm login
```

## MCP registration

```bash
claude mcp add --transport http --scope user notebooklm http://localhost:17200/mcp
```

## ai-stack compose snippet

```yaml
notebooklm-mcp:
  image: ghcr.io/kpiwko/notebooklm-mcp:latest
  networks: [ai-stack]
  ports:
    - "17200:17200"
    - "17201:6080"
  volumes:
    - /Users/kpiwko/.config/notebooklm-mcp-cli:/root/.config/notebooklm-mcp-cli
  restart: unless-stopped
```

## Building locally

Requires a RHEL subscription (passed through automatically by Podman Desktop's RHEL machine).
Store activation key credentials for CI-style builds:

```bash
mkdir -p ~/.config/rhsm && chmod 700 ~/.config/rhsm
echo "your-org-id" > ~/.config/rhsm/org && chmod 600 ~/.config/rhsm/org
echo "your-activation-key" > ~/.config/rhsm/key && chmod 600 ~/.config/rhsm/key
./scripts/build-local.sh
```

## CI/CD

GitHub Actions builds and pushes to `ghcr.io/kpiwko/notebooklm-mcp` on push to `main` and on version tags.

Required GitHub secrets:

| Secret | Source |
|--------|--------|
| `RH_REGISTRY_USER` | https://access.redhat.com/terms-based-registry/ |
| `RH_REGISTRY_TOKEN` | https://access.redhat.com/terms-based-registry/ |
| `RHSM_ORG` | https://console.redhat.com/insights/connector/activation-keys |
| `RHSM_KEY` | https://console.redhat.com/insights/connector/activation-keys |
