#!/usr/bin/env bash
# ============================================================
# init-project.sh — Template project initializer
#
# Usage:
#   ./init-project.sh [project-name]
#
#  - If omitted, the current folder name is used as default.
#
# Examples:
#   ./init-project.sh myapp-mcp-server
#   ./init-project.sh        # → uses current folder name
#
# Actions:
#   1. Validate project name (kebab-case: lowercase + numbers + hyphens)
#   2. Replace "template-mcp-server" → new name across all files
#   3. Update COMPOSE_PROJECT_NAME in .env
#   4. Update name & bin in package.json
#   5. Update server name & log messages in src/index.ts
#   6. Update title in README.md
#   7. Update devcontainer.json
#   9. Print next steps
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

# ── Argument handling ─────────────────────────────────────────────────
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEFAULT_NAME="$(basename "$SCRIPT_DIR")"

if [ $# -lt 1 ]; then
  NEW_NAME="$DEFAULT_NAME"
  printf "\n"
  info "No project name provided. Using current folder name: ${NEW_NAME}"
  read -p "Proceed with this name? [Y/n]: " -n 1 -r REPLY
  printf "\n"
  if [[ "$REPLY" =~ ^[Nn]$ ]]; then
    printf "\n"
    printf "Usage: %s <project-name>\n" "$0"
    printf "\n"
    printf "  Project name must be kebab-case.\n"
    printf "  Example: myapp-mcp-server, order-service-mcp\n"
    printf "\n"
    exit 0
  fi
else
  NEW_NAME="$1"
fi

# kebab-case validation
if ! printf '%s' "$NEW_NAME" | grep -qE '^[a-z0-9]+(-[a-z0-9]+)*$'; then
  error "Project name must be kebab-case (lowercase letters, numbers, hyphens. e.g. myapp-mcp-server)"
fi

OLD_NAME="template-mcp-server"

printf "\n"
printf "========================================\n"
printf "  Project Initialization\n"
printf "========================================\n"
printf "\n"
info "Old name: ${OLD_NAME}"
info "New name: ${NEW_NAME}"
printf "\n"

# ── Target files ──────────────────────────────────────
TARGET_FILES=(
  "package.json"
  "src/index.ts"
  "README.md"
  ".env"
  "docker-compose.dev.yml"
  ".devcontainer/devcontainer.json"
)

# ── Step 1: Replace strings in all files ─────────────────────────
info "Replacing strings in files..."

for file in "${TARGET_FILES[@]}"; do
  filepath="${SCRIPT_DIR}/${file}"
  if [ -f "$filepath" ]; then
    if [[ "$(uname)" == "Darwin" ]]; then
      sed -i '' "s/${OLD_NAME}/${NEW_NAME}/g" "$filepath"
    else
      sed -i "s/${OLD_NAME}/${NEW_NAME}/g" "$filepath"
    fi
    success "  Replaced: ${file}"
  else
    warn "  Not found: ${file} (skipped)"
  fi
done

# ── Step 2: Replace service name in docker-compose.dev.yml ──────────────
COMPOSE_FILE="${SCRIPT_DIR}/docker-compose.dev.yml"
if [ -f "$COMPOSE_FILE" ]; then
  if [[ "$(uname)" == "Darwin" ]]; then
    sed -i '' "s/  ${OLD_NAME}:/  ${NEW_NAME}:/g" "$COMPOSE_FILE"
  else
    sed -i "s/  ${OLD_NAME}:/  ${NEW_NAME}:/g" "$COMPOSE_FILE"
  fi
  success "  Service name replaced in docker-compose.dev.yml"
fi

# ── Step 3: CamelCase replacement in src/index.ts ──────────────────────
OLD_NAME_CAMEL=$(printf '%s' "$OLD_NAME" | sed 's/-//g')
NEW_NAME_CAMEL=$(printf '%s' "$NEW_NAME" | sed 's/-//g')

if [ "$OLD_NAME_CAMEL" != "$NEW_NAME_CAMEL" ]; then
  INDEX_FILE="${SCRIPT_DIR}/src/index.ts"
  if [ -f "$INDEX_FILE" ]; then
    if [[ "$(uname)" == "Darwin" ]]; then
      sed -i '' "s/${OLD_NAME_CAMEL}/${NEW_NAME_CAMEL}/g" "$INDEX_FILE"
    else
      sed -i "s/${OLD_NAME_CAMEL}/${NEW_NAME_CAMEL}/g" "$INDEX_FILE"
    fi
    success "  CamelCase replaced: ${OLD_NAME_CAMEL} → ${NEW_NAME_CAMEL}"
  fi
fi

# ── Done ─────────────────────────────────────────────────
printf "\n"
printf "========================================\n"
printf "  ${GREEN}Project initialization complete!${NC}\n"
printf "========================================\n"
printf "\n"
printf "Next steps:\n"
printf "  1. pnpm install\n"
printf "  2. pnpm build\n"
printf "  3. docker compose -f docker-compose.dev.yml up -d\n"
printf "\n"
printf "Or use Devcontainer:\n"
printf "  → Run 'Reopen in Container' in VS Code\n"
printf "\n"
