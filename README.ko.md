# 🌙 AI Night Shift

> 멀티 에이전트 자율 프레임워크 — AI 어시스턴트가 당신이 잠든 사이에 일합니다.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![English](https://img.shields.io/badge/lang-English-blue)](README.md)
[![繁體中文](https://img.shields.io/badge/lang-繁體中文-orange)](README.zh-TW.md)
[![简体中文](https://img.shields.io/badge/lang-简体中文-red)](README.zh-CN.md)

**AI Night Shift**는 업무 외 시간에 여러 AI 에이전트(Claude Code, Gemini 등)를 조율하여 자율적으로 작업하게 하는 오픈소스 프레임워크입니다. 30회 이상의 실제 프로덕션 야간 근무 경험에서 탄생했습니다. 이론이 아닌 실전 검증된 시스템입니다.

## 차별점

대부분의 '자율 에이전트' 도구는 단일 에이전트만 실행합니다. AI Night Shift는 **여러 이기종 AI 에이전트**가 함께 협업하도록 오케스트레이션합니다:

| 에이전트 | 엔진 | 역할 | 모드 |
|---------|------|------|------|
| 개발자 | Claude Code | 코딩, 디버깅, 배포 | 연속 실행 (수 시간) |
| 연구원 | Gemini CLI | 리서치, 데이터 수집, 분류 | 주기적 순찰 (수 분) |
| 코디네이터 | 임의 LLM | 태스크 라우팅, 모니터링 | 하트비트 (30분) |

공유 프로토콜을 통해 통신합니다 — 파일 기반 메시지 큐, 공유 채팅 로그, 태스크 관리 통합.

## 아키텍처

```
┌─────────────────────────────────────────────┐
│              AI Night Shift                  │
│                                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  │
│  │ Claude   │  │ Gemini   │  │ 하트비트  │  │
│  │ Code     │  │ CLI      │  │ Agent    │  │
│  └────┬─────┘  └────┬─────┘  └────┬─────┘  │
│       └──────┬───────┴──────┬───────┘        │
│       ┌──────▼──────┐ ┌────▼─────┐          │
│       │ night_chat  │ │ bot_inbox│          │
│       │    .md      │ │  (JSON)  │          │
│       └─────────────┘ └──────────┘          │
│                                              │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  │
│  │ 플러그인  │  │ 대시보드  │  │ 템플릿   │  │
│  └──────────┘  └──────────┘  └──────────┘  │
└─────────────────────────────────────────────┘
```

## 빠른 시작

### 1. 설치

```bash
git clone https://github.com/judyailab/ai-night-shift.git
cd ai-night-shift
bash install.sh
```

### 2. 설정

```bash
cp config.env.example config.env
nano config.env
```

### 3. 테스트

```bash
# 1라운드만 실행하여 설정 확인
bash claude-code/night_shift.sh --max-rounds 1
```

### 4. 스케줄링

```bash
crontab -e
# 추가: 0 1 * * * cd ~/ai-night-shift && bash claude-code/wrapper.sh
```

## 모듈

| 모듈 | 설명 | 문서 |
|------|------|------|
| [Claude Code](claude-code/) | 연속 개발자 세션 | [README](claude-code/README.md) |
| [Gemini](gemini/) | 주기적 순찰 및 리서치 | [README](gemini/README.md) |
| [OpenClaw](openclaw/) | 하트비트 코디네이터 패턴 | [README](openclaw/README.md) |
| [프로토콜](protocols/) | 에이전트 간 통신 | [README](protocols/README.md) |
| [플러그인](plugins/) | 확장 가능한 pre/post/task 훅 | [README](plugins/README.md) |
| [대시보드](dashboard/) | 시각적 모니터링 인터페이스 | `dashboard/index.html` 열기 |
| [템플릿](templates/) | 용도별 프롬프트 템플릿 | 4개 포함 |

## 프롬프트 템플릿

| 템플릿 | 용도 |
|--------|------|
| `development.txt` | 코딩, 테스트, 디버깅 |
| `research.txt` | 데이터 수집, 분석 |
| `content.txt` | 글쓰기, 번역, SEO |
| `maintenance.txt` | 시스템 관리, 모니터링 |

## 플러그인 시스템

```bash
# 플러그인 활성화
ln -s plugins/examples/system_health.sh plugins/enabled/

# 모든 플러그인 목록
bash plugins/plugin_loader.sh --list
```

기본 플러그인: 시스템 헬스 체크, 백업, Git 커밋 요약, 모닝 리포트

## 대시보드

브라우저에서 `dashboard/index.html`을 열고 리포트 파일을 드래그 앤 드롭하세요:
- 에이전트 활동 및 상태
- 라운드별 타임라인
- 야간 채팅 메시지
- 시스템 헬스 지표

## 고급 기능

- **완료 시그널** — 에이전트가 "작업 완료"를 알려 조기 종료 가능
- **공유 태스크 노트** — 라운드 간 컨텍스트 메모리 브릿지
- **De-Sloppify 패턴** — 별도의 코드 품질 정리 패스
- **안티패턴 가이드** — 흔한 자율 루프 함정 방지

## 요구사항

- **Bash 4+** 및 **Python 3.6+**
- AI CLI 도구 하나 이상:
  - [Claude Code](https://docs.anthropic.com/en/docs/claude-code)
  - [Gemini CLI](https://github.com/google-gemini/gemini-cli)
- Linux/macOS 시스템 (cron 또는 기타 스케줄러)

## 보안

- **PID 잠금**으로 동시 실행 방지
- **시간 윈도우**로 정시 종료 보장
- **레이트 리밋 처리**로 자동 대기 및 재시도
- **코드에 시크릿 없음** — 모두 환경 변수 사용
- **추가 전용 통신** — 에이전트가 서로의 메시지를 삭제할 수 없음
- **플러그인 타임아웃** — 플러그인당 최대 5분 실행

## 기여

[CONTRIBUTING.md](CONTRIBUTING.md)를 참조하세요.

## 라이선스

[MIT](LICENSE) — Judy AI Lab

---

*30회 이상의 자율 야간 근무 실전 경험에서 탄생. AI가 당신이 잠든 사이 더 열심히 일하게 하세요.* 🌙
