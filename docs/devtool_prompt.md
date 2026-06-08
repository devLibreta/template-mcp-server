# Devtool Prompt (reference)

> Original prompt used to generate this template. Kept for reference only.

---

You are an expert in Docker, VS Code Devcontainer, and MCP (Model Context Protocol) environment setup.
I want to create an "MCP development environment suite" where all development happens inside Docker containers (Devcontainer), keeping my host machine (Mac mini) clean.

[Current infrastructure]

1. Host OS: Mac mini (M-series / ARM64)
2. Docker runtime: OrbStack
3. Host state: No Node.js, npm, Java, or any dev tools installed (and I don't want them)
4. Development workflow:
   - Use VS Code Devcontainer to mount host source folder into container
   - All TypeScript writing, pnpm dependency management, and builds happen inside the container
   - Git commits and GitHub pushes also happen inside the container
5. MCP transport: SSE (Server-Sent Events), port 3000
6. Working folder name: devtool-mcp-server (same as project name)

[Requirements]

1. Git credential forwarding:
   - Mount host Git config and SSH keys read-only into container:
     - `~/.gitconfig:/root/.gitconfig:ro`
     - `~/.ssh:/root/.ssh:ro`
2. Dockerfile:
   - Filename: `Dockerfile.dev`
   - Assumes source is mounted from host — no COPY of source code
   - Base image: `node:22-alpine`
   - Enable corepack and pnpm
   - Switch to non-root `node` user
3. Source initialization:
   - Use `@modelcontextprotocol/create-server` via temporary Docker container
   - Project name matches folder name
   - Use `--name`, `--description` flags to skip interactive prompts
   - Pipe `echo "sse"` for transport selection
   - Two-step: create in temp dir, then move to project root
   - Auto-remove temp container with `--rm`
   - Convert generated stdio code to SSE (express + StreamableHTTPServerTransport)
   - Use Zod schemas for `server.tool()` (required for MCP SDK v1.29.0+)
4. devcontainer.json:
   - Path: `.devcontainer/devcontainer.json`
   - `dockerfile: "../Dockerfile.dev"`, `context: ".."`
   - Port forwarding: 3000
   - `postCreateCommand`: `"pnpm install && pnpm build"`
   - `remoteUser: "node"`
   - `runArgs: ["--platform=linux/arm64"]`
   - Recommended VS Code extensions: eslint, prettier, docker, path-intellisense, code-spell-checker, pretty-ts-errors, errorlens
   - TypeScript SDK path: `js/ts.tsdk.path` (not deprecated `typescript.tsdk`)
   - Default terminal: zsh

[Expected outputs]

1. `BOOTSTRAP_GUIDE.md` — Full workflow from zero to running Devcontainer
2. `.devcontainer/devcontainer.json`
3. `Dockerfile.dev`
