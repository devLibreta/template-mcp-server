# 컨테이너 실행 가이드

## 컨테이너 시작

```bash
docker compose -f docker-compose.dev.yml up -d
```

## 컨테이너 내부 접속

```bash
docker exec -it template-mcp-server zsh
```

## 서비스 실행

컨테이너 접속 후 아래 스크립트로 MCP 서버와 Inspector를 동시에 실행합니다.

```bash
./start-dev.sh
```

### 수동 실행

```bash
# 1. MCP 서버 실행 (백그라운드)
npx tsx watch src/index.ts &

# 2. MCP Inspector 실행 (백그라운드)
npx @modelcontextprotocol/inspector &
```

## 접속 URL

| 서비스        | URL                            |
| ------------- | ------------------------------ |
| MCP 서버      | `http://localhost:3000/mcp`    |
| 헬스체크      | `http://localhost:3000/health` |
| MCP Inspector | `http://localhost:6274`        |

## 컨테이너 종료

```bash
docker compose -f docker-compose.dev.yml down
```
