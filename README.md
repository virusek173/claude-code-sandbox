# Claude Code Sandbox

A sandboxed version of Claude Code running in Docker. The container sees **only** the project directory you launch it from — no other files on disk are accessible.

---

## Requirements

- Docker Desktop (installed and running)
- Anthropic Pro/Max plan (OAuth)

---

## Installation — step by step

### 1. Clone the repository

```bash
git clone https://github.com/virusek173/claude-code-sandbox.git ~/tools/claude-code-sandbox
```

### 2. Build the Docker image

```bash
cd ~/tools/claude-code-sandbox
make build
```

This takes ~1-2 minutes the first time (downloads Node.js + installs Claude Code).

### 3. Make the script executable

```bash
chmod +x ~/tools/claude-code-sandbox/claude-sandbox
```

### 4. Add an alias to ~/.zshrc

```bash
echo 'alias claude="$HOME/tools/claude-code-sandbox/claude-sandbox"' >> ~/.zshrc
source ~/.zshrc
```

### 5. First session — OAuth login

```bash
cd ~/your-project
claude
```

On the first run, Claude Code will ask you to log in via the browser —
click the link, log in, and you're done. The token is saved to `~/.claude/`
and shared across sessions.

---

## Daily use

Just like before:

```bash
cd ~/projects/my-project
claude
```

Or with a one-shot prompt:

```bash
cd ~/projects/my-project
claude "explain the directory structure in src/"
```

**Under the hood, a container starts that sees ONLY ~/projects/my-project.**

Other directories (e.g. ~/projects/other-project, ~/.ssh, ~/.env) simply don't exist
from Claude Code's perspective.

---

## Updating Claude Code

When a new version is released:

```bash
cd ~/tools/claude-code-sandbox
make rebuild
```

---

## Verifying isolation

You can check that the container really can't see your files:

```bash
cd /tmp
mkdir test-sandbox && cd test-sandbox
echo "test" > visible.txt

claude "check if you can read ~/.ssh/id_rsa or ~/projects/my-project"
# Claude Code will NOT be able to — those paths don't exist in the container
```

---

## Troubleshooting

| Problem | Solution |
|---------|----------|
| `Docker is not running` | Start Docker Desktop |
| OAuth token expired | Run `claude` — browser login will start automatically |
| File permission issues | `make rebuild` (rebuilds with the correct UID) |
| Want to update Claude Code | `make rebuild` |

---

## What the container mounts

| Mount | Source → Target | Description |
|-------|-----------------|-------------|
| Project | `$(pwd)` → `/workspace` | Your current directory — the **only** accessible directory |
| Auth | `~/.claude` → `/home/developer/.claude` | OAuth tokens (persistent across sessions) |

Nothing else is mounted. The rest of the disk is invisible.

---

## Git inside the container

Git works inside the container with the following behaviour:

- **Identity** (`user.name`, `user.email`) is read from the **local project config** (`.git/config`), not from `~/.gitconfig`. This means you can have different git identities per project and the global config won't leak in.
- **SSH keys are NOT available** inside the container, so `git push` over SSH will not work. Use HTTPS with a personal access token, or configure the remote accordingly.

To set per-project git identity before using the sandbox:

```bash
cd ~/projects/my-project
git config user.name "Your Name"
git config user.email "you@example.com"
```

---

## Linux compatibility

The Dockerfile defines default UID/GID values (`501`/`20`) matching typical macOS users, but the build script always passes the **actual host values** via `--build-arg USER_UID=$(id -u)` and `--build-arg USER_GID=$(id -g)`. The sandbox works on Linux without any changes.