# Claude Code — sandboxed container
# Only the mounted project directory is accessible
FROM node:22-slim

ARG USER_UID=501
ARG USER_GID=20

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
    && rm -rf /var/lib/apt/lists/* \
    && npm install -g @anthropic-ai/claude-code \
    && groupadd -g ${USER_GID} developer 2>/dev/null || true \
    && useradd -m -u ${USER_UID} -g ${USER_GID} -s /bin/bash developer \
    && git config --system --add safe.directory /workspace

# Install hook that blocks reading sensitive files (PreToolUse)
COPY block-sensitive-files.sh /usr/local/bin/block-sensitive-files
COPY entrypoint.sh /usr/local/bin/entrypoint

RUN chmod +x /usr/local/bin/block-sensitive-files /usr/local/bin/entrypoint \
    && mkdir -p /home/developer/.claude \
    && chown -R ${USER_UID}:${USER_GID} /home/developer/.claude

WORKDIR /workspace
USER developer

ENTRYPOINT ["entrypoint"]
