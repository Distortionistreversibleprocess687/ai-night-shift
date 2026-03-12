# 고급 가이드

## 다중 에이전트 설정

AI Night Shift의 진정한 힘은 여러 에이전트를 함께 실행할 때 발휘됩니다.

### 권장 구성

```
에이전트 1 (Claude Code) — 지속적인 개발자
  일정:凌晨 1시 - 오전 7시
  작업: 코딩, 테스트, 배포

에이전트 2 (Gemini) — 주기적인 연구자
  일정: 에이전트 1 실행 중 2시간마다
  작업: 연구, 분류, 문서화

에이전트 3 (Heartbeat) — 코디네이터
  일정: 30분마다
  작업: 받은 편지함 항목 라우팅, 건강 모니터링, 작업 배포
```

### 에이전트 간 통신 설정

1. **에이전트 받은 편지함 생성:**
```bash
mkdir -p protocols/bot_inbox/{claude,gemini,heartbeat}/{done}
```

2. **각 모듈의 환경에서 에이전트 이름 구성:**
```bash
# Claude Code 세션에서
export AGENT_NAME=gemini

# Gemini 순찰에서
export AGENT_NAME=gemini
```

3. **에이전트가 서로에게 메시지 전송:**
```bash
# Claude가 Gemini에게 연구 요청
./protocols/msg.sh gemini "Please research React Server Components best practices"

# Gemini가 결과를 보고
./protocols/notify.sh claude RESEARCH-1 success "Findings in reports/rsc_research.md"
```

## 작업 보드 통합

선호하는 작업 관리에 연결:

**Linear:**
```bash
export TASK_TOOL="linear"
# 설치: pip install linear-sdk
```

**GitHub Issues:**
```bash
export TASK_TOOL="github"
# 사용: gh cli
```

**일반 파일:**
```bash
export TASK_TOOL="file"
# 사용: 체크박스 형식의 tasks.md
```

## 사용자 정의 플러그인

### 플러그인 API

플러그인은 다음 환경 변수에 액세스할 수 있습니다:

| 변수 | 설명 |
|----------|-------------|
| `NIGHT_SHIFT_DIR` | 프레임워크 루트 디렉토리 |
| `AGENT_NAME` | 현재 에이전트 식별자 |
| `DATE_TAG` | 현재 날짜 (YYYY-MM-DD) |

및 이러한 디렉토리:

| 경로 | 용도 |
|------|---------|
| `$NIGHT_SHIFT_DIR/logs/` | 로그 출력 쓰기 |
| `$NIGHT_SHIFT_DIR/reports/` | 보고서 파일 쓰기 |
| `$NIGHT_SHIFT_DIR/protocols/` | 메시지 읽기/쓰기 |

### 플러그인 수명 주기

```
프리 플러그인  → 야간 근무 전 실행 (상태 확인, 백업)
작업 플러그인  → 각 라운드 동안 실행 (사용자 정의 자동화)
포스트 플러그인 → 야간 근무 후 실행 (보고서, 정리)
```

### 예: 사용자 정의 모니터링 플러그인

```bash
#!/usr/bin/env bash
# PLUGIN_NAME: Database Monitor
# PLUGIN_PHASE: pre
# PLUGIN_DESCRIPTION: 데이터베이스 연결 및 쿼리 성능 확인

set -euo pipefail
NIGHT_SHIFT_DIR="${NIGHT_SHIFT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"

# 데이터베이스 연결 확인
if pg_isready -h localhost -p 5432 2>/dev/null; then
    echo "Database: OK"
else
    echo "WARNING: Database unreachable"
    # 다른 에이전트를 위해 night_chat에 쓰기
    echo "[$(date '+%H:%M')] DBMonitor: Database connection failed!" \
        >> "$NIGHT_SHIFT_DIR/protocols/night_chat.md"
fi
```

## 확장

### 여러 프로젝트

다른 프로젝트에 대해 별도의 야간 근무 실행:

```bash
# 프로젝트 A — 웹 개발
NIGHT_SHIFT_DIR=~/project-a/night-shift \
  bash ~/ai-night-shift/claude-code/night_shift.sh --prompt project_a_prompt.txt

# 프로젝트 B — 데이터 파이프라인
NIGHT_SHIFT_DIR=~/project-b/night-shift \
  bash ~/ai-night-shift/claude-code/night_shift.sh --prompt project_b_prompt.txt
```

### 평일 vs 주말

다른 일정 및 프롬프트 사용:

```
# 평일: 집중 개발
0 1 * * 1-5 cd ~/ai-night-shift && bash claude-code/wrapper.sh

# 주말: 연구 및 정리
0 1 * * 0,6 cd ~/ai-night-shift && PROMPT_FILE=templates/maintenance.txt bash claude-code/wrapper.sh
```

## 루프 패턴 (참조)

AI Night Shift는 확립된 자율 루프 패턴을 기반으로 합니다. 이를 이해하면 올바른 구성을 선택하는 데 도움이 됩니다:

| 패턴 | 구현 | 최적 |
|---------|-------------------|----------|
| 순차 파이프라인 | `night_shift.sh` 라운드 | 다단계 개발 워크플로 |
| 주기적 순찰 | `patrol.sh` | 가벼운 체크인 |
| Heartbeat | OpenClaw 모듈 | 코디네이터/라우터 에이전트 |
| De-Sloppify | `de_sloppify.sh` 플러그인 | 코딩 후 품질 정리 |
| 완료 신호 | `night_shift.sh` 내장 | 지능형 조기 종료 |
| 공유 작업 노트 | `shared_task_notes.md` | 라운드 간 컨텍스트 브릿지 |

### 완료 신호

에이전트가 "	done"을 나타내기 위해 매직 구문을 출력할 수 있습니다. 신호가 연속 N번 나타나면 근무가 일찍 종료됩니다:

```bash
# config.env에서
COMPLETION_SIGNAL="NIGHT_SHIFT_COMPLETE"
COMPLETION_THRESHOLD=2  # 연속 2번의 신호 후 중지
```

프롬프트 템플릿에서 에이전트에게 알려주세요:
```
모든 작업이 완료되고 할 일이 없으면,
출력에 텍스트 NIGHT_SHIFT_COMPLETE를 포함하세요.
```

### 공유 작업 노트 (라운드 간 메모)

각 `claude -p` 호출은 새 컨텍스트로 시작합니다. `shared_task_notes.md`를 사용하여 컨텍스트를 브릿지하세요:

```markdown
## 진행 상황
- [x] auth 모듈 리팩토링 (라운드 1)
- [x] 15개 단위 테스트 추가 (라운드 2)
- [ ] 아직 필요: OAuth 흐름에 대한 통합 테스트

## 다음 라운드 참고
- tests/helpers.ts의 mock 설정을 재사용 가능
- Rate limiting 엔드에 경합 조건 — 뮤텍스 필요
```

프롬프트 템플릿에 `{SHARED_NOTES}`를 추가하여 자동으로 주입하세요.

### De-Sloppify 패턴

AI에게 "조잡한 코드를 쓰지 마라"고 말하는 대신(품질 저하), 정리 전달을 위해 `de_sloppify.sh` 플러그인을 활성화하세요:

```bash
ln -s ../examples/de_sloppify.sh plugins/enabled/
```

이는 각 개발 라운드 후 실행되어 다음을 제거합니다:
- 언어/프레임워크 동작을 확인하는 테스트 (비즈니스 로직 아님)
- 타입 시스템이 이미 적용하는 중복 타입 검사
- 디버그 인쇄 문장 및 주석 처리된 코드

### 피해야 할 안티 패턴

1. **종료 조건 없는 무한 루프** — 항상 `MAX_ROUNDS`, `WINDOW_HOURS`를 설정하거나 완료 신호를 사용하세요
2. **컨텍스트 브릿지 없음** — `shared_task_notes.md` 없으면 각 라운드가 작업을 반복합니다
3. **같은 실패 재시도** — 오류 컨텍스트를 캡처하고 전달하세요, 그냥 재시도하지 마세요
4. **부정적 지시** — "X를 하지 마라"고 말하면 품질이 저하됩니다; 대신 정리 전달을 사용하세요
5. **하나의 프롬프트에 모든 로직** — 다른 라운드/에이전트로 관심을 분리하세요

## Telegram 통합

### 설정

1. [@BotFather](https://t.me/BotFather)를 통해 Telegram Bot 생성
2..chat ID 가져오기
3. `config.env`에 추가:
```bash
TELEGRAM_BOT_TOKEN=your_token
TELEGRAM_CHAT_ID=your_chat_id
```

4. 아침 보고서 플러그인 활성화:
```bash
ln -s ../examples/morning_report.sh plugins/enabled/
```

### 전송 내용

아침 보고서 플러그인은 각 근무 후 요약을 전송합니다:
- 완료된 작업
- 발견된 문제
- 생성된 Git 커밋
- 시스템 상태
