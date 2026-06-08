# Project Initialization Guide

> How to convert this template into your own MCP server project.

---

## Quick Start (automated)

### Step 1: Run the init script

```bash
./init-project.sh [project-name]
```

- If omitted, the current folder name is used as default.

**Examples:**

```bash
./init-project.sh myapp-mcp-server
./init-project.sh        # → uses current folder name
```

### Step 2: Start developing

```bash
# Docker Compose
docker compose -f docker-compose.dev.yml up -d

# Or VS Code Devcontainer
# → "Reopen in Container"
```

`pnpm install && pnpm build` runs automatically on container start.

---

## What the script does

| Action | Details |
| --- | --- |
| String replacement | `template-mcp-server` → new name across all files |
| `package.json` | Updates `name` and `bin` keys |
| `src/index.ts` | Updates server name and log messages |
| `README.md` | Updates title |
| `.env` | Updates `COMPOSE_PROJECT_NAME` |
| `docker-compose.dev.yml` | Updates default env values |
| `.devcontainer/devcontainer.json` | Updates container name |

---

## Manual replacement

If you prefer not to use the script:

### 1. `.env`

```bash
COMPOSE_PROJECT_NAME=<new-project-name>
```

### 2. `package.json`

```json
{
  "name": "<new-project-name>",
  "bin": {
    "<new-project-name>": "./dist/index.js"
  }
}
```

### 3. `src/index.ts`

```typescript
const server = new McpServer({
  name: "<new-project-name>",
  version: "0.1.0",
});
```

### 4. Remaining files

```bash
grep -rl "template-mcp-server" . --exclude-dir=node_modules --exclude-dir=dist | \
  xargs sed -i '' 's/template-mcp-server/<new-project-name>/g'
```

---

## Notes

- **Project name rule**: kebab-case only (lowercase letters, numbers, hyphens)
  - ✅ `myapp-mcp-server`, `order-service`
  - ❌ `MyApp`, `my_app`, `myapp--server`
- Run `pnpm install` again after replacement (lockfile needs refresh).
- `dist/` is a build artifact — not a replacement target. Rebuild with `pnpm build`.
