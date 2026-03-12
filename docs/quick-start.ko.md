# 빠른 시작 가이드

5분 안에 AI 나이트십을 실행하세요.

## 전제 조건

- Linux 또는 macOS
- Bash 4+ 및 Python 3.6+
- 최소 하나의 AI CLI 도구 설치:
  - **Claude Code:** `npm install -g @anthropic-ai/claude-code`
  - **Gemini CLI:** `npm install -g @google/gemini-cli`

## 1단계: 설치

```bash
git clone https://github.com/judyailab/ai-night-shift.git
cd ai-night-shift
bash install.sh
```

인스톨러가 수행하는 작업:
- 디렉토리 구조 생성
- 파일 권한 설정
- cron 작업 선택적 구성

## 2단계: 구성

```bash
cp config.env.example config.env
nano config.env
```

조정할 주요 설정:
- `WINDOW_HOURS` — 나이트십 실행 시간
- `MAX_ROUNDS` — 최대 라운드 수
- `CLAUDE_BIN` / `GEMINI_BIN` — CLI 도구への 경로

## 3단계: 프롬프트 사용자 정의

프롬프트 템플릿을 편집하여 AI에게 수행할 작업을 지정하세요:

```bash
nano claude-code/prompt_template.txt
```

또는 사전 빌드된 템플릿 중 하나를 사용하세요:
```bash
cp templates/development.txt claude-code/prompt_template.txt
```

## 4단계: 테스트

단일 라운드를 실행하여 모든 것이 작동하는지 확인하세요:

```bash
bash claude-code/night_shift.sh --max-rounds 1
```

출력 확인:
```bash
cat reports/$(date +%Y-%m-%d)_round1.md
```

## 5단계: 예약

인스톨러가 cron 작업을 자동으로 설정할 수 있습니다. 수동으로 설정하려면:

```bash
crontab -e
```

선호하는 일정을 추가하세요:
```
# Night shift at 1 AM (adjust timezone)
0 1 * * * cd ~/ai-night-shift && bash claude-code/wrapper.sh >> logs/cron.log 2>&1

# Gemini patrol every 2 hours during night
0 1,3,5,7 * * * cd ~/ai-night-shift && bash gemini/patrol.sh >> logs/patrol.log 2>&1
```

## 6단계: 플러그인 활성화 (선택사항)

```bash
# Enable system health check (runs before shift)
ln -s ../examples/system_health.sh plugins/enabled/system_health.sh

# Enable morning report (runs after shift)
ln -s ../examples/morning_report.sh plugins/enabled/morning_report.sh
```

## 7단계: 모니터링

대시보드 열기:
```bash
open dashboard/index.html
# or
xdg-open dashboard/index.html
```

보고서 파일을 드래그 앤 드롭하여 나이트십 활동을 시각화하세요.

## 다음 단계

- **[아키텍처](architecture.ko.md)** — 시스템 작동 방식 이해
- **[고급 가이드](advanced.ko.md)** — 멀티 에이전트 설정, 커스텀 플러그인
- **[문제 해결](troubleshooting.ko.md)** — 일반적인 문제 및 해결 방법
