# Claude Code — sandboxed container
# Only the mounted project directory is accessible
FROM node:22-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    bash \
    curl \
    git \
    openssh-client \
    ca-certificates \
    jq \
    less \
    vim \
    ripgrep \
    && rm -rf /var/lib/apt/lists/*

# Install Claude Code globally
RUN npm install -g @anthropic-ai/claude-code

# Create non-root user matching typical macOS UID
ARG USER_UID=501
ARG USER_GID=20
RUN groupadd -g ${USER_GID} developer 2>/dev/null || true \
    && useradd -m -u ${USER_UID} -g ${USER_GID} -s /bin/bash developer

# Git config (container-level defaults)
RUN git config --system --add safe.directory /workspace

WORKDIR /workspace
USER developer

ENTRYPOINT ["claude"]
