.PHONY: build rebuild clean status

IMAGE_NAME = claude-code-sandbox

## build  — build image (skips if already exists)
build:
	@if ! docker image inspect $(IMAGE_NAME) &>/dev/null; then \
		echo "🔨 Building $(IMAGE_NAME)..."; \
		docker build \
			--build-arg USER_UID=$$(id -u) \
			--build-arg USER_GID=$$(id -g) \
			-t $(IMAGE_NAME) .; \
		echo "✅ Done!"; \
	else \
		echo "ℹ️  Image $(IMAGE_NAME) already exists. Use 'make rebuild' to force rebuild."; \
	fi

## rebuild — rebuild image from scratch (e.g. after Claude Code update)
rebuild:
	@echo "🔨 Rebuilding $(IMAGE_NAME)..."
	@docker build --no-cache \
		--build-arg USER_UID=$$(id -u) \
		--build-arg USER_GID=$$(id -g) \
		-t $(IMAGE_NAME) . && echo "✅ Done!"

## clean  — remove image
clean:
	docker rmi $(IMAGE_NAME) 2>/dev/null || true
	@echo "🧹 Image removed."

## status — show status
status:
	@echo "=== Image ==="
	@docker image inspect $(IMAGE_NAME) --format '{{.Id}} ({{.Size}} bytes)' 2>/dev/null || echo "Not found"
	@echo ""
	@echo "=== Running containers ==="
	@docker ps --filter ancestor=$(IMAGE_NAME) --format 'table {{.Names}}\t{{.Status}}\t{{.Mounts}}' 2>/dev/null || echo "None"
