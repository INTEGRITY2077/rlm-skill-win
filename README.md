# RLM Skill - Windows Fork

> Windows-optimized fork of the [RLM Skill](https://github.com/BowTiedSwan/rlm-skill)

**Recursive Language Model (RLM)** - 대규모 코드베이스(100+ 파일)를 병렬 처리하는 Claude Code 스킬

## Features

- Windows 전용 설치 스크립트 (BAT, PowerShell)
- 한국어 예제 및 문서
- Claude Code / Claude Agent SDK 호환

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

1. **Index & Filter** - `grep`, `find`로 관련 파일 필터링
2. **Parallel Map** - 3-5개 에이전트가 병렬로 파일 분석
3. **Reduce** - 결과 종합 및 패턴 파악
4. **Recursive** - 필요시 추가 분석 반복

### Why RLM?

| Approach | Files | Context Usage | Speed |
|----------|-------|---------------|-------|
| Traditional | 30-50 | 100% (exhausted) | Slow |
| RLM | 100+ | 20% (efficient) | Fast |

## Requirements

- **Python 3.6+** (no external packages needed)
- **Windows 10+** (curl or PowerShell)
- **Claude Code** or compatible AI agent

## File Structure

```
rlm-skill-win/
├── SKILL.md              # Skill definition
├── rlm.py                # Python engine
├── install-windows.bat   # Batch installer
├── install-windows.ps1   # PowerShell installer
├── README.md             # This file
├── EXAMPLES.md           # Usage examples
└── test-rlm.bat          # Installation test
```

## Credits

- **Original**: [BowTiedSwan/rlm-skill](https://github.com/BowTiedSwan/rlm-skill)
- **Paper**: ArXiv 2512.24601 - "Recursive Language Models"
- **Windows Fork**: Enhanced for Windows users with Korean docs

## License

MIT License - Same as original project
