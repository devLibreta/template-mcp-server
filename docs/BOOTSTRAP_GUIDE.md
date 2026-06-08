# MCP Project Bootstrap Guide

> **Target**: From a Mac mini with no dev tools installed, use Docker to scaffold a TypeScript + pnpm MCP project via `@modelcontextprotocol/create-server`.
> Uses Node.js 22 LTS (latest as of June 2026).

---

## Prerequisites

```bash
# Verify Docker (OrbStack) is running
docker info

# Create project directory
mkdir -p ~/workspace/my-mcp-server
```

---

## Step 1: Scaffold with `@modelcontextprotocol/create-server`

This runs the official MCP project generator inside a temporary container.
The project name matches the current folder name (`my-mcp-server`).

```bash
# 1) Create a temporary output directory
mkdir -p /tmp/mcp-create-output

docker run --rm \
  -v /tmp/mcp-create-output:/workspace \
  node:22-alpine \
  sh -c '
    corepack enable && corepack prepare pnpm@9 --activate && \
    cd /workspace && \
    echo "sse" | pnpm create @modelcontextprotocol/create-server@latest my-mcp-server \
      --name my-mcp-server \
      --description "MCP SSE server"
  '

# 2) Move generated files to project root
cp -r /tmp/mcp-create-output/my-mcp-server/* ~/workspace/my-mcp-server/

# 3) Clean up
rm -rf /tmp/mcp-create-output
```

### Command breakdown

| Part | Meaning |
| --- | --- |
| `docker run --rm` | Auto-remove container after exit |
| `node:22-alpine` | Node.js 22 LTS base image |
| `pnpm@9` | Stable pnpm for Node.js 22 |
| `--name my-mcp-server` | Skip interactive name prompt |
| `--description "..."` | Skip interactive description prompt |
| `echo "sse" \|` | Auto-answer transport prompt |
| `cp -r /tmp/...` | Avoid nested folder duplication |

---

## Step 2: Convert to SSE transport

`create-server` always generates **stdio** code regardless of the transport choice.
Overwrite `src/index.ts` with an SSE implementation:

```bash
cat > src/index.ts << 'EOF'
#!/usr/bin/env node

/**
 * MCP SSE Server — my-mcp-server
 * Transport: SSE (Server-Sent Events) via Streamable HTTP
 * Port: 3000 (configurable via MCP_PORT env)
 * Output: dist/index.js
 */

import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StreamableHTTPServerTransport } from "@modelcontextprotocol/sdk/server/streamableHttp.js";
import express from "express";
import { z } from "zod";

const server = new McpServer(
  { name: "my-mcp-server", version: "0.1.0" },
  { capabilities: { resources: {}, tools: {}, prompts: {} } }
);

server.tool(
  "echo",
  "Echo back the provided message",
  { message: z.string().describe("Message to echo back") },
  async ({ message }) => ({
    content: [{ type: "text" as const, text: `Echo: ${message}` }],
  })
);

const app = express();
app.use(express.json());

app.post("/mcp", async (req, res) => {
  try {
    const transport = new StreamableHTTPServerTransport({
      sessionIdGenerator: undefined,
    });
    res.on("close", () => transport.close());
    await server.connect(transport);
    await transport.handleRequest(req, res);
  } catch (error) {
    console.error("MCP request error:", error);
    res.status(500).json({ error: "Internal server error" });
  }
});

app.get("/health", (_req, res) => {
  res.json({ status: "ok", transport: "sse" });
});

const PORT = Number(process.env.MCP_PORT) || 3000;
app.listen(PORT, () => {
  console.log(`MCP SSE Server running on port ${PORT}`);
});
EOF
```

Update dependencies:

```bash
pnpm add express zod
pnpm add -D @types/express
```

---

## Step 3: Verify structure

```bash
cd ~/workspace/my-mcp-server
find . -not -path '*/node_modules/*' -not -path '*/.git/*' -not -path '*/dist/*'
```

Expected:

```
my-mcp-server/
├── .devcontainer/
│   └── devcontainer.json
├── .env
├── .gitignore
├── docker-compose.dev.yml
├── Dockerfile.dev
├── package.json
├── pnpm-lock.yaml
├── README.md
├── tsconfig.json
└── src/
    └── index.ts
```

---

## Step 4: Start developing

```bash
code ~/workspace/my-mcp-server
```

In VS Code: `Cmd + Shift + P` → **"Dev Containers: Reopen in Container"**

`pnpm install && pnpm build` runs automatically via `postCreateCommand`.

---

## Step 5: Git commit & push

Host `~/.gitconfig` and `~/.ssh` are mounted read-only into the container.

```bash
git init
git add .
git commit -m "feat: initial MCP SSE server scaffold"
git remote add origin git@github.com:your-id/my-mcp-server.git
git push -u origin main
```

---

## Cleanup

```bash
docker system prune -f
```
