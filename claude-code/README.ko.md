# Claude Code 야간 근무 모듈

비근무 시간에 [Claude Code](https://docs.anthropic.com/en/docs/claude-code)를 자동 실행하고, 자동 재시도, Rate Limit 처리 및 구조화된 보고서를 제공합니다.

## 작동 방식

```
┌─ Cron이 야간 시간에 트리거 ─┐
│                              │
│  라운드 1  →  라운드 2  →  라운드 N    │
│  (2.5시간)    (2.5시간)    (창이        │
│                           끝날 때까지)   │
│                              │
│  PID 잠금으로 동시 실행 방지        │
│  Rate Limit → 자동 대기 60분        │
│  타임아웃 → 다음 라운드            │
└──────────────────────────────────────┘
```

## 빠른 시작

```bash
# 단일 라운드로 테스트
./night_shift.sh --max-rounds 1

# 전체 야간 근무 (5 라운드, 6시간 창)
./night_shift.sh

# 사용자 정의 구성
./night_shift.sh --max-rounds 3 --window-hours 8 --prompt my_prompt.txt
```

## 구성

| 변수 | 기본값 | 설명 |
|----------|---------|-------------|
| `MAX_ROUNDS` | 5 | 각 근무당 최대 라운드 수 |
| `WINDOW_HOURS` | 6 | 총 시간 창(시간) |
| `ROUND_TIMEOUT` | 9000 (2.5시간) | 라운드당 최대 초 |
| `RATE_LIMIT_WAIT` | 3600 (1시간) | Rate Limit 대기 초 |
| `SHUTDOWN_BUFFER` | 300 (5분) | 창 닫기 전 버퍼 |
| `CLAUDE_BIN` | `claude` | Claude Code CLI 경로 |

## Cron 설정

```bash
# 현지 시간 오전 1시 실행, 월-금
0 1 * * 1-5 cd ~/ai-night-shift && bash claude-code/night_shift.sh >> logs/cron.log 2>&1
```

## 프롬프트 사용자 정의

`prompt_template.txt`를 편집하여 야간 근무 중 Claude Code가 수행할 작업을 정의하세요. 사용 가능한 템플릿 변수:

- `{ROUND}` — 현재 라운드 번호
- `{MAX_ROUNDS}` — 구성된 총 라운드 수
- `{DATE}` — 현재 날짜
- `{REMAINING_TIME}` — 창에 남은 시간
