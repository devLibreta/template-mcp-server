# template-mcp-server

MCP SSE server template — clone and customize for your own MCP server projects.

## Features

### Tools

- `echo` — Echo back a provided message
  - `message` (string): Message to echo back

### Endpoints

| Method | Path      | Description         |
| ------ | --------- | ------------------- |
| POST   | `/mcp`    | MCP Streamable HTTP |
| GET    | `/health` | Health check        |

## Documentation

| Guide | Description |
| --- | --- |
| [docs/BOOTSTRAP_GUIDE.md](docs/BOOTSTRAP_GUIDE.md) | Create a brand-new MCP project from scratch using Docker (no local dev tools needed) |
| [docs/PROJECT_INIT_GUIDE.md](docs/PROJECT_INIT_GUIDE.md) | Convert this template into your own project with `init-project.sh` |

## Development

### Using Devcontainer (recommended)

Open in VS Code and run **"Dev Containers: Reopen in Container"**.
Dependencies and build are automatic.

### Using Docker Compose

```bash
docker compose -f docker-compose.dev.yml up -d
```

`pnpm install && pnpm build` runs automatically on container start.

### Manual (host machine)

```bash
pnpm install
pnpm build
pnpm start
```

The server runs on port 3000 by default (configurable via `MCP_PORT` env).

### Scripts

| Command | Description |
| --- | --- |
| `pnpm build` | Compile TypeScript to `dist/` |
| `pnpm start` | Run the MCP SSE server |
| `pnpm dev` | Watch mode for development |
| `pnpm inspector` | Launch MCP Inspector for debugging |
