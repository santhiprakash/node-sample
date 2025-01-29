# Base: Minimal Ubuntu 24.04 (~80MB)
FROM ubuntu:24.04

# System tools with NO recommended packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    xz-utils \
    && rm -rf /var/lib/apt/lists/*

# -------------------------------
# Install Node.js (Latest) via binary (~50MB)
# -------------------------------
ARG NODE_VERSION=20.12.2
RUN curl -fsSL https://nodejs.org/dist/v${NODE_VERSION}/node-v${NODE_VERSION}-linux-x64.tar.xz \
    | tar -xJ -C /usr/local --strip-components=1 --no-same-owner

# -------------------------------
# Install .NET 8 SDK via script (~200MB)
# -------------------------------
#RUN curl -fsSL https://dot.net/v1/dotnet-install.sh -o dotnet-install.sh \
#    && chmod +x dotnet-install.sh \
#    && ./dotnet-install.sh --install-dir /usr/share/dotnet -channel 8.0 \
#    && ln -s /usr/share/dotnet/dotnet /usr/bin/dotnet \
#    && rm dotnet-install.sh

# Create non-root user
RUN useradd -m vscode
USER vscode
