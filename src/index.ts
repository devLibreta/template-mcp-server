import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StreamableHTTPServerTransport } from "@modelcontextprotocol/sdk/server/streamableHttp.js";
import express from "express";
import { z } from "zod";

// 1. MCP 서버 선언
const server = new McpServer({
  name: "template-mcp-server",
  version: "0.1.0",
});

server.tool(
  "echo",
  "Echo back the provided message",
  { message: z.string().describe("Message to echo back") },
  async ({ message }) => ({
    content: [{ type: "text" as const, text: `Echo: ${message}` }],
  }),
);

const app = express();

// 2. 전역 Transport 선언
const mcpTransport = new StreamableHTTPServerTransport();

// ⭕ 핵심: MCP 라우터 내부를 극도로 단순화합니다.
// 전역 mcpTransport에 요청을 그대로 '토스'만 해야 내부 세션 테이블(6de55b43-...)이 깨지지 않습니다.
app.post("/mcp", async (req, res) => {
  try {
    // 만약 앞선 미들웨어가 바디를 훼손했다면 복구하는 방어 코드
    if (
      req.body &&
      typeof req.body === "object" &&
      !Buffer.isBuffer(req.body)
    ) {
      req.body = Buffer.from(JSON.stringify(req.body));
    }

    // 절대 여기서 transport.close()를 바인딩하지 마세요!
    await mcpTransport.handleRequest(req, res);
  } catch (error) {
    console.error("❌ MCP Engine Internal Error:", error);
    if (!res.headersSent) {
      res.status(500).json({ error: "Internal server error" });
    }
  }
});

// 다른 API용 미들웨어는 항상 MCP 아래에 배치
app.use(express.json());

app.get("/health", (_req, res) => {
  res.json({ status: "ok" });
});

// 3. 🚀 서버 기동 함수 (비동기 순서 보장 패턴)
async function startServer() {
  try {
    // 반드시 MCP 서버 커넥션이 "완 완료"된 후에 Express 포트를 열어야 합니다.
    console.log("🔄 Connecting MCP server to Streamable HTTP transport...");
    await server.connect(mcpTransport);
    console.log("🔗 MCP Server connected successfully.");

    const PORT = Number(process.env.MCP_PORT) || 3000;
    app.listen(PORT, () => {
      console.log(`✅ MCP SSE Server [devtool] running on port ${PORT}`);
      console.log(`   Health: http://localhost:${PORT}/health`);
      console.log(`   MCP:    http://localhost:${PORT}/mcp`);
    });
  } catch (err) {
    console.error("❌ Failed to start server:", err);
    process.exit(1);
  }
}

startServer();
