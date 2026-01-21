# RLM Skill - Windows Fork

> Windows-optimized fork of the [RLM Skill](https://github.com/BowTiedSwan/rlm-skill)

**Recursive Language Model (RLM)** - 대규모 코드베이스(100+ 파일)를 병렬 처리하는 Claude Code 스킬

## ⚠️ Windows 특이사항 (2026-01 업데이트)

### Claude Code SDK 동시성 제한

Windows에서 병렬 백그라운드 태스크 실행 시 다음 에러가 발생할 수 있습니다:

```
API Error: 400 due to tool use concurrency issues
```

**원인**: Claude Code SDK Issue [#6836](https://github.com/anthropics/claude-code/issues/6836) - tool_use/tool_result 블록 불일치

### 병렬 모드 실패 증상

| 증상 | 설명 |
|------|------|
| API Error 400 | 동시성 충돌로 API 거부 |
| 출력 파일 비어있음 | 에이전트 실행됨, 결과 누락 |
| 토큰 소비, 결과 없음 | 작업 수행 후 전달 실패 |

**테스트 결과 (2026-01-22):**
```
4개 병렬 에이전트 실행 → 130k tokens 소비 → 0개 유용한 결과
```

### 권장 실행 모드

| 모드 | Windows | Linux/Mac |
|------|---------|-----------|
| **Mode A: Parallel** | ❌ 권장하지 않음 | ✅ OK (v2.1.9+) |
| **Mode B: Sequential** | ✅ 권장 | ✅ OK |
| **Mode C: Direct Tool** | ✅ 최고 권장 | ✅ OK |

### Claude Code 버전 호환성

| 버전 | 병렬 태스크 지원 |
|------|-----------------|
| < v2.1.7 | ❌ 자주 실패 |
| v2.1.7 - v2.1.8 | ⚠️ 부분 수정 |
| >= v2.1.9 | ✅ 수정됨 |

버전 확인: `claude --version`

### WSL 대안 (병렬 모드 필요 시)

Windows에서 병렬 모드가 필요하다면 **WSL(Windows Subsystem for Linux)** 사용:

```bash
# WSL 진입
wsl

# Claude Code 버전 확인
claude --version  # v2.1.9+ 필요

# RLM 스킬 설치
mkdir -p ~/.claude/skills/rlm
cp /mnt/d/path/to/rlm-skill-win/SKILL.md ~/.claude/skills/rlm/
cp /mnt/d/path/to/rlm-skill-win/rlm.py ~/.claude/skills/rlm/

# 병렬 모드 테스트
claude "RLM: analyze codebase"
```

| 환경 | 병렬 모드 |
|------|----------|
| Windows Native | ❌ 불안정 |
| **WSL (Linux)** | ✅ 안정 (v2.1.9+) |

---

## Features

- ✅ Windows 전용 설치 스크립트 (BAT, PowerShell)
- ✅ Claude Code SDK 동시성 이슈 대응
- ✅ 3가지 실행 모드 (Parallel/Sequential/Direct Tool)
- ✅ UTF-8 한국어 지원

## Quick Install

### Option 1: PowerShell (권장)
```powershell
Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
.\install-windows.ps1
```

### Option 2: Batch Script
```batch
install-windows.bat
```

### Option 3: Manual
```batch
mkdir %USERPROFILE%\.claude\skills\rlm
copy SKILL.md %USERPROFILE%\.claude\skills\rlm\
copy rlm.py %USERPROFILE%\.claude\skills\rlm\
```

## Verify Installation

```batch
dir %USERPROFILE%\.claude\skills\rlm
```

Expected output:
```
SKILL.md
rlm.py
```

## Usage

### Trigger Keywords
Claude Code에서 다음 키워드로 자동 활성화:
- `"analyze codebase"`
- `"scan all files"`
- `"large repository"`
- `"RLM"`
- `"find usage of X across the project"`

### Example Commands

```
RLM: scaleFactor가 사용되는 모든 파일을 찾아줘

analyze codebase: onResize 콜백 체인을 추적해줘

large repository: 로그 파일에서 에러 패턴 분석해줘
```

### Python CLI

```batch
REM 파일 스캔
python %USERPROFILE%\.claude\skills\rlm\rlm.py scan

REM 패턴 검색
python %USERPROFILE%\.claude\skills\rlm\rlm.py peek "scaleFactor"

REM 청크 분할
python %USERPROFILE%\.claude\skills\rlm\rlm.py chunk --pattern "*.log"
```

## How RLM Works

### The 4-Phase Protocol

1. **Index & Filter** - `Glob`, `Grep` 도구로 관련 파일 필터링
2. **Map (3가지 모드)**
   - **Mode A (Parallel)**: 3-5개 에이전트 동시 분석 (Linux/Mac, v2.1.9+)
   - **Mode B (Sequential)**: 에이전트 순차 실행 (Windows 권장)
   - **Mode C (Direct Tool)**: Grep/Read 직접 사용 (가장 빠름, <50 파일)
3. **Reduce** - 결과 종합 및 패턴 파악
4. **Recursive** - 필요시 추가 분석 반복

### Why RLM?

| Approach | Files | Context Usage | Speed |
|----------|-------|---------------|-------|
| Traditional | 30-50 | 100% (exhausted) | Slow |
| RLM | 100+ | 20% (efficient) | Fast |

## Recovery Mode

### API Error 400 발생 시:
1. 병렬 실행 즉시 중단
2. Sequential Mode 또는 Direct Tool Mode로 전환
3. 병렬 재시도 금지 (에러 지속됨)

### 백그라운드 태스크 출력 파일이 비어있을 때:
1. 에이전트가 조용히 실패한 것
2. Direct Tool Mode로 전환: Grep + Read 직접 사용
3. 또는 Python 스크립트로 분석

## Requirements

- **Python 3.6+** (no external packages needed)
- **Windows 10+** (curl or PowerShell)
- **Claude Code** or compatible AI agent

## File Structure

```
rlm-skill-win/
├── SKILL.md              # Skill definition (v2 with 3 modes)
├── rlm.py                # Python engine (UTF-8 support)
├── install-windows.bat   # Batch installer
├── install-windows.ps1   # PowerShell installer
├── README.md             # This file
├── EXAMPLES.md           # Usage examples
└── test-rlm.bat          # Installation test
```

## Credits

- **Original**: [BowTiedSwan/rlm-skill](https://github.com/BowTiedSwan/rlm-skill)
- **Paper**: ArXiv 2512.24601 - "Recursive Language Models"
- **Windows Fork**: Enhanced for Windows with SDK concurrency workarounds

## License

MIT License - Same as original project
