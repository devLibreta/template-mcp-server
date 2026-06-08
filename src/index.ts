#!/usr/bin/env node

/**
 * MCP SSE Server — template-mcp-server
 * Transport: SSE (Server-Sent Events) via Streamable HTTP
 * Port: 3000 (configurable via MCP_PORT env)
 * Output: dist/index.js
 */

import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StreamableHTTPServerTransport } from "@modelcontextprotocol/sdk/server/streamableHttp.js";
import express from "express";
import { z } from "zod";

// ── MCP Server 인스턴스 생성 ──────────────────────────────────
const server = new McpServer(
  {
    name: "template-mcp-server",
    version: "0.1.0",
  },
  {
    capabilities: {
      resources: {},
      tools: {},
      prompts: {},
    },
  },
);

// ── 예시 도구: echo ───────────────────────────────────────────
server.tool(
  "echo",
  "Echo back the provided message",
  { message: z.string().describe("Message to echo back") },
  async ({ message }) => ({
    content: [{ type: "text" as const, text: `Echo: ${message}` }],
  }),
);

// ── Express 앱 설정 ───────────────────────────────────────────
const app = express();
app.use(express.json());

// Streamable HTTP 엔드포인트
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

// 헬스체크
app.get("/health", (_req, res) => {
  res.json({ status: "ok", server: "devtool", transport: "sse" });
});

// ── 서버 시작 ─────────────────────────────────────────────────
const PORT = Number(process.env.MCP_PORT) || 3000;

app.listen(PORT, () => {
  console.log(`✅ MCP SSE Server [devtool] running on port ${PORT}`);
  console.log(`   Health: http://localhost:${PORT}/health`);
  console.log(`   MCP:    http://localhost:${PORT}/mcp`);
});
