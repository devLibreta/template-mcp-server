#!/bin/bash
# ============================================================
# start-dev.sh — MCP 서버 + Inspector 동시 실행
# 컨테이너 내부에서 실행: ./start-dev.sh
# ============================================================

set -e

echo "🚀 Starting MCP Server..."
npx tsx watch src/index.ts &
MCP_PID=$!

echo "🔍 Starting MCP Inspector..."
npx @modelcontextprotocol/inspector &
INSP_PID=$!

echo ""
echo "✅ Services started!"
echo "   MCP Server  → http://localhost:3000"
echo "   Inspector   → http://localhost:6274"
echo ""
echo "Press Ctrl+C to stop all services."

# 종료 시 두 프로세스 모두 정리
trap "kill $MCP_PID $INSP_PID 2>/dev/null; exit" INT TERM

wait
