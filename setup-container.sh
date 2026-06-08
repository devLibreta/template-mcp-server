#!/usr/bin/env bash
# ============================================================
# setup-container.sh — Dev Container 의존성 설치 & 빌드
#
# 컨테이너가 시작된 후 다음 작업을 자동으로 수행합니다:
#   1. /workspace 소유권 수정 (node 사용자)
#   2. pnpm install
#   3. pnpm build
#
# Usage:
#   ./setup-container.sh
#
# Prerequisites:
#   - Docker가 실행 중이어야 합니다.
#   - docker compose up -d 로 컨테이너가 시작된 상태여야 합니다.
# ============================================================

set -euo pipefail

# ── Colors ─────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

info()    { printf "${BLUE}[INFO]${NC} %s\n" "$*"; }
success() { printf "${GREEN}[OK]${NC} %s\n" "$*"; }
warn()    { printf "${YELLOW}[WARN]${NC} %s\n" "$*"; }
error()   { printf "${RED}[ERROR]${NC} %s\n" "$*"; exit 1; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

COMPOSE_FILE="docker-compose.dev.yml"
CONTAINER_NAME="template-mcp-server"

# ── Step 0: Docker 확인 ──────────────────────────────────────────
info "Checking Docker..."
if ! docker info >/dev/null 2>&1; then
  error "Docker is not running. Please start Docker first."
fi
success "Docker is running"

# ── Step 1: 컨테이너 존재 확인 ──────────────────────────────────
info "Checking container status..."
if ! docker ps --format '{{.Names}}' | grep -qx "$CONTAINER_NAME"; then
  warn "Container '${CONTAINER_NAME}' is not running."
  info "Starting container with docker compose..."
  docker compose -f "$COMPOSE_FILE" up -d
  success "Container started"
fi

# ── Step 2: 컨테이너 준비 대기 ─────────────────────────────────
info "Waiting for container to be ready..."
for i in $(seq 1 30); do
  if docker exec "$CONTAINER_NAME" echo "ready" >/dev/null 2>&1; then
    success "Container is ready"
    break
  fi
  if [ "$i" -eq 30 ]; then
    error "Container did not become ready in 30 seconds"
  fi
  sleep 1
done

# ── Step 3: /workspace 소유권 수정 ─────────────────────────────
info "Fixing /workspace ownership (chown node:node)..."
docker exec -u root "$CONTAINER_NAME" chown -R node:node /workspace
success "Ownership fixed"

# ── Step 4: pnpm install ───────────────────────────────────────
info "Running pnpm install..."
docker exec -u node "$CONTAINER_NAME" sh -c \
  "pnpm config set store-dir /workspace/.pnpm-store && pnpm install"
success "pnpm install complete"

# ── Step 5: pnpm build ─────────────────────────────────────────
info "Running pnpm build..."
docker exec -u node "$CONTAINER_NAME" pnpm build
success "pnpm build complete"

# ── Done ───────────────────────────────────────────────────────
printf "\n"
printf "========================================\n"
printf "  ${GREEN}Container setup complete!${NC}\n"
printf "========================================\n"
printf "\n"
printf "Next steps:\n"
printf "  → Run 'Reopen in Container' in VS Code\n"
printf "  → Or: docker exec -it -u node ${CONTAINER_NAME} zsh\n"
printf "\n"
