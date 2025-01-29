# Use Ubuntu 22.04 LTS as base
FROM ubuntu:24.04

# Arguments for build-time configuration
ARG GIT_EMAIL
ARG GIT_NAME
ARG NODE_VERSION=20
ARG DEBIAN_FRONTEND=noninteractive

# Install essential packages and Node.js
RUN apt-get update && apt-get install -y --no-install-recommends \
    ca-certificates \
    curl \
    git \
    gnupg \
    ssh-client \
    && mkdir -p /etc/apt/keyrings \
    && curl -fsSL https://deb.nodesource.com/gpgkey/nodesource-repo.gpg.key | gpg --dearmor -o /etc/apt/keyrings/nodesource.gpg \
    && echo "deb [signed-by=/etc/apt/keyrings/nodesource.gpg] https://deb.nodesource.com/node_${NODE_VERSION}.x nodistro main" | tee /etc/apt/sources.list.d/nodesource.list \
    && apt-get update \
    && apt-get install -y nodejs \
    && npm install -g npm@latest \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Create non-root user
ARG USERNAME=devuser
ARG USER_UID=1000
ARG USER_GID=$USER_UID

RUN groupadd --gid $USER_GID $USERNAME \
    && useradd --uid $USER_UID --gid $USER_GID -m $USERNAME \
    && mkdir -p /home/$USERNAME/.ssh \
    && chown -R $USERNAME:$USERNAME /home/$USERNAME/.ssh \
    && chmod 700 /home/$USERNAME/.ssh

# Switch to non-root user
USER $USERNAME
WORKDIR /home/$USERNAME

# Copy cloud-init configuration
COPY --chown=$USERNAME:$USERNAME cloud-config.yml /home/$USERNAME/.cloud-init/config.yml

# Setup Git configuration
RUN git config --global user.email "${GIT_EMAIL}" \
    && git config --global user.name "${GIT_NAME}" \
    && git config --global credential.helper store

# Create workspace directory
RUN mkdir -p /home/$USERNAME/workspace
WORKDIR /home/$USERNAME/workspace

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD node --version || exit 1
