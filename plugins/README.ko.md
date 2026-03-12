# 플러그인 시스템

사용자 정의 플러그인으로 야간 근무를 확장하세요. 플러그인은 야간 근무 수명 주기의 특정 단계에서 실행됩니다.

## 단계

| 단계 | 실행 시기 | 사용 사례 |
|-------|------|----------|
| `pre` | 야간 근무 시작 전 | 시스템 상태 확인, 백업, 데이터 수집 |
| `task` | 각 라운드 동안 | 사용자 정의 작업, 모니터링, 보고서 |
| `post` | 야간 근무 종료 후 | 보고서 생성, 정리, 알림 |

## 플러그인 생성

이러한 헤더 주석이 있는 bash 스크립트 생성:

```bash
#!/usr/bin/env bash
# PLUGIN_NAME: My Plugin
# PLUGIN_PHASE: pre
# PLUGIN_DESCRIPTION: 기능에 대한简要한 설명

set -euo pipefail

NIGHT_SHIFT_DIR="${NIGHT_SHIFT_DIR:-$(cd "$(dirname "$0")/../.." && pwd)}"

# 여기에 코드
echo "Plugin running!"
```

## 플러그인 활성화

```bash
# 예제 플러그인 활성화
ln -s ../examples/system_health.sh plugins/enabled/system_health.sh

# 또는 복사 및 사용자 정의
cp plugins/examples/system_health.sh plugins/enabled/
```

## 사용 가능한 예제 플러그인

| 플러그인 | 단계 | 설명 |
|-----------|-------|-------------|
| `system_health.sh` | pre | 디스크, 메모리, Docker 상태 확인 |
| `backup.sh` | pre | 설정 및 채팅 기록 백업 |
| `git_commit_summary.sh` | post | 모든 커밋의 요약 |
| `morning_report.sh` | post | 아침 브리핑 편집 + TG 푸시 |

## 플러그인 실행

```bash
# 활성화된 모든 플러그인 실행
./plugins/plugin_loader.sh

# 프리 시프트 플러그인만 실행
./plugins/plugin_loader.sh --phase pre

# 모든 플러그인 나열
./plugins/plugin_loader.sh --list
```

## 플러그인 가이드라인

1. **타임아웃:** 각 플러그인 최대 5분 실행 시간
2. **종료 코드:** 성공은 0, 실패는 0이 아님 (근무 차단 안 함)
3. **로깅:** stdout에 쓰기 - 로더가 캡처함
4. **시크릿 없음:** API 키 하드코딩 안 함; 환경 변수 사용
5. **멱등:** 플러그인이 여러 번 실행될 수 있음; 우아하게 처리
