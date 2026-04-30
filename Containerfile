FROM registry.access.redhat.com/ubi9/python-312:latest

LABEL name="notebooklm-mcp" \
      summary="NotebookLM MCP Server" \
      description="MCP server providing Google NotebookLM access via browser automation" \
      maintainer="kpiwko@redhat.com"

USER root

# EPEL provides x11vnc and noVNC (pulls in websockify); Chromium system deps below
RUN dnf install -y \
    https://dl.fedoraproject.org/pub/epel/epel-release-latest-9.noarch.rpm \
    && dnf install -y \
    xorg-x11-server-Xvfb x11vnc novnc xorg-x11-utils \
    alsa-lib at-spi2-atk at-spi2-core atk cairo cups-libs \
    dbus-libs expat flac-libs gdk-pixbuf2 glib2 glibc gtk3 \
    libX11 libXcomposite libXdamage libXext libXfixes libXrandr \
    libXtst libcanberra-gtk3 libdrm libgcc libstdc++ libxcb \
    libxkbcommon libxshmfence libxslt mesa-libgbm nspr nss \
    nss-util pango zlib \
    && dnf clean all && rm -rf /var/cache/dnf

RUN pip install --upgrade pip uv \
    && uv tool install notebooklm-mcp-cli==0.6.1 \
    && pip install playwright \
    && playwright install --only-shell chromium \
    && pip uninstall -y playwright

ENV DISPLAY=:99 \
    PATH="/root/.local/bin:$PATH"

VOLUME ["/root/.notebooklm-mcp-cli"]

EXPOSE 17200 6080

COPY scripts/entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

CMD ["/entrypoint.sh"]
