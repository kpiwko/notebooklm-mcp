FROM registry.redhat.io/ubi9/python-312:latest

LABEL name="notebooklm-mcp" \
      summary="NotebookLM MCP Server" \
      description="MCP server providing Google NotebookLM access via browser automation" \
      maintainer="kpiwko@redhat.com"

USER root

# Conditionally register RHEL subscription via activation key if secrets are provided.
# Local builds: pass --secret id=rhsm_org,src=<file> --secret id=rhsm_key,src=<file>
# CI builds: RHSM_ORG and RHSM_KEY repository secrets (see .github/workflows/build.yaml)
# Registry pull (registry.redhat.io) uses a separate service account token — unrelated to these secrets.
# EPEL provides x11vnc and noVNC (websockify); xorg-x11-server-Xvfb and xorg-x11-utils from AppStream.
RUN --mount=type=secret,id=rhsm_org \
    --mount=type=secret,id=rhsm_key \
    if [ -f /run/secrets/rhsm_org ]; then \
      subscription-manager register \
        --org=$(cat /run/secrets/rhsm_org) \
        --activationkey=$(cat /run/secrets/rhsm_key) || true; \
    fi \
    && dnf install -y \
      https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm \
    && dnf install -y \
      xorg-x11-server-Xvfb x11vnc novnc xorg-x11-utils \
      alsa-lib at-spi2-atk at-spi2-core atk cairo cups-libs \
      dbus-libs expat flac-libs gdk-pixbuf2 glib2 glibc gtk3 \
      libX11 libXcomposite libXdamage libXext libXfixes libXrandr \
      libXtst libcanberra-gtk3 libdrm libgcc libstdc++ libxcb \
      libxkbcommon libxshmfence libxslt mesa-libgbm nspr nss \
      nss-util pango zlib \
    && (subscription-manager unregister 2>/dev/null || true) \
    && dnf clean all && rm -rf /var/cache/dnf

# Set HOME explicitly — the UBI9 python-312 base image carries HOME=/opt/app-root/src
# in its environment; without this override uv installs to the wrong directory.
ENV HOME=/root

RUN pip install --upgrade pip uv \
    && uv tool install --python python3.12 notebooklm-mcp-cli==0.6.3 \
    && pip install playwright \
    && playwright install chromium \
    && pip uninstall -y playwright \
    && printf '#!/bin/sh\nexec "$(find /root/.cache/ms-playwright/chromium-* -name chrome -type f | head -1)" --no-sandbox "$@"\n' > /usr/local/bin/chromium-browser \
    && chmod +x /usr/local/bin/chromium-browser

ENV DISPLAY=:99 \
    PATH="/root/.local/bin:$PATH" \
    NOTEBOOKLM_MCP_HOST=0.0.0.0 \
    NOTEBOOKLM_MCP_CLI_PATH=/root/.config/notebooklm-mcp-cli

VOLUME ["/root/.config/notebooklm-mcp-cli"]

EXPOSE 17200 6080

COPY scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
