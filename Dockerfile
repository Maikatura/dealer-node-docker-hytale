# ==============================================================================
# Hytale Server Docker Image (root version)
# ==============================================================================
FROM eclipse-temurin:25-jdk

LABEL maintainer="Dealer Node <administration@dealernode.app>"
LABEL description="Hytale Game Server (root)"
LABEL version="1.0.0"

# Install dependencies
RUN apt-get update && apt-get install -y \
    curl \
    unzip \
    bash \
    jq \
    screen \
    && rm -rf /var/lib/apt/lists/*

# Set working directory to /server
WORKDIR /server

# Create necessary directories
RUN mkdir -p /server/universe /server/mods /server/config

# Download hytale-downloader CLI
RUN curl -fsSL -o hytale-downloader.zip "https://downloader.hytale.com/hytale-downloader.zip" && \
    unzip -o hytale-downloader.zip && \
    mv hytale-downloader-linux-amd64 hytale-downloader && \
    chmod +x hytale-downloader && \
    rm hytale-downloader.zip hytale-downloader-windows-amd64.exe QUICKSTART.md 2>/dev/null || true

# Copy entrypoint script
COPY --chmod=755 entrypoint.sh /entrypoint.sh

# Expose UDP port for QUIC protocol
EXPOSE 5520/udp

# Default environment variables
ENV SERVER_NAME="Hytale Server - (Loser Node)"
ENV MAX_PLAYERS=10
ENV MEMORY_MB=4096
ENV AUTH_MODE=authenticated
ENV VIEW_DISTANCE=10

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=60s --retries=3 \
    CMD pgrep -f "HytaleServer.jar" || exit 1

# Run as root (default)
ENTRYPOINT ["/entrypoint.sh"]
