# ==============================================================================
# Hytale Server Docker Image
# ==============================================================================
# Runs a Hytale game server with automatic updates via hytale-downloader.
# SECURITY: No credentials are stored in this image. All authentication
# tokens must be provided at runtime via environment variables.
# ==============================================================================

FROM eclipse-temurin:25-jdk

LABEL maintainer="Dealer Node <administration@dealernode.app>"
LABEL description="Hytale Game Server"
LABEL version="1.0.0"

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    bash \
    jq \
    screen \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user for security
RUN groupadd --system hytale && \
    useradd --system --gid hytale --create-home --home-dir /Server hytale

# Set working directory to /Server
WORKDIR /server

# Make sure /Server is fully writable
RUN mkdir -p /Server && \
    chown -R hytale:hytale /Server

# Download hytale-downloader CLI
RUN curl -fsSL -o hytale-downloader.zip "https://downloader.hytale.com/hytale-downloader.zip" && \
    unzip -o hytale-downloader.zip && \
    mv hytale-downloader-linux-amd64 hytale-downloader && \
    chmod +x hytale-downloader && \
    rm hytale-downloader.zip hytale-downloader-windows-amd64.exe QUICKSTART.md 2>/dev/null || true

# Create directories for persistent data
RUN mkdir -p universe mods config

# Copy entrypoint script
COPY --chown=hytale:hytale --chmod=755 entrypoint.sh /entrypoint.sh

# Expose UDP port for QUIC protocol
EXPOSE 5520/udp

# Default environment variables (no secrets here!)
ENV SERVER_NAME="Hytale Server - (Loser Node)"
ENV MAX_PLAYERS=10
ENV MEMORY_MB=4096
ENV AUTH_MODE=authenticated
ENV VIEW_DISTANCE=10

# Health check - verify server process is running
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD pgrep -f "HytaleServer.jar" || exit 1

# Run as non-root user
USER hytale

# Entrypoint
ENTRYPOINT ["/entrypoint.sh"]
