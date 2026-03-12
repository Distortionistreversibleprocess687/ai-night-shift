# Gemini 순찰 모듈

[Gemini CLI](https://github.com/google-gemini/gemini-cli)의 주기적 순찰 실행기입니다. 빈번한 가벼운 체크인에 설계되었으며 긴 연속 세션이 아닙니다.

## 작동 방식

```
Cron (매 1-2시간)
  → 받은 편지함 항목 수집
  → 최근 팀 채팅 읽기
  → 컨텍스트 인식 프롬프트 구축
  → Gemini CLI 실행
  → 결과 night chat에 게시
  → 처리된 항목을 done/으로 이동
```

## 빠른 시작

```bash
# 단일 순찰 실행
./patrol.sh

# 사용자 정의 프롬프트 사용
./patrol.sh --prompt my_patrol_prompt.txt
```

## 구성

| 변수 | 기본값 | 설명 |
|----------|---------|-------------|
| `GEMINI_BIN` | `gemini` | Gemini CLI 경로 |
| `NIGHT_SHIFT_DIR` | 자동 감지 | 프레임워크 루트 디렉토리 |

## Cron 설정

```bash
# 야간 근무 중 2시간마다 순찰 (오전 1시 - 오전 7시)
0 1,3,5,7 * * * cd ~/ai-night-shift && bash gemini/patrol.sh >> logs/patrol.log 2>&1
```

## 최적 사용 사례

Gemini의 강점(그라운딩, 검색, 큰 컨텍스트)으로 다음에 이상적입니다:
- **리서치 작업** — 웹 검색, 데이터 수집
- **작업 분류** — 받은 편지함 읽기, 다른 에이전트로 작업 라우팅
- **문서화** — 요약 작성, 보고서 포맷
- **번역** — 콘텐츠 현지화
