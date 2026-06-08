# 컨테이너 기능 명세

## 개요

`template-mcp-server` 개발 컨테이너는 MCP(Model Context Protocol) 서버 개발을 위한 환경을 제공합니다.

## 실행 환경

| 항목          | 내용             |
| ------------- | ---------------- |
| 베이스 이미지 | `node:22-slim`   |
| 기본 셸       | `zsh`            |
| 실행 유저     | `node` (비-root) |
| 작업 디렉토리 | `/workspace`     |

## 포트

| 포트   | 용도                           |
| ------ | ------------------------------ |
| `3000` | MCP 서버 (SSE/Streamable HTTP) |
| `6274` | MCP Inspector (UI)             |
| `6277` | MCP Inspector (Proxy)          |

## 사용 가능한 기능

### Git

- `git` 클라이언트가 설치되어 있으며, 호스트의 `~/.gitconfig`와 `~/.ssh`가 마운트되어 있어 커밋 및 SSH 푸시가 가능합니다.

### MCP Inspector

- `@modelcontextprotocol/inspector`가 백그라운드로 실행되어 브라우저에서 MCP 서버를 테스트하고 디버깅할 수 있습니다.

### 패키지 매니저

- **pnpm** (v11) — 기본 패키지 매니저
- **npm** — Node.js 기본 내장

### 개발 서버

- `npx tsx watch src/index.ts`로 TypeScript 소스 변경 시 자동 재시작되는 MCP 서버가 실행됩니다.

## 볼륨 마운트

| 경로             | 용도                            |
| ---------------- | ------------------------------- |
| `. → /workspace` | 호스트 소스 코드                |
| `node_modules`   | 의존성 캐시 (named volume)      |
| `.pnpm-store`    | pnpm 스토어 캐시 (named volume) |
| `~/.gitconfig`   | Git 설정 (read-only)            |
| `~/.ssh`         | SSH 키 (read-only)              |
