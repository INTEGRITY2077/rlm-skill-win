# RLM Implementations Comparison

> 경쟁 레포지토리와의 비교우위 점검표

## 비교 대상

| 레포지토리 | 설명 | Stars |
|------------|------|-------|
| **rlm-skill-win** (우리) | Windows 최적화 포크 | - |
| BowTiedSwan/rlm-skill | 원본 RLM 스킬 | - |
| brainqub3/claude_code_RLM | Sub-LLM 패턴 구현 | ~130 |

---

## 기능 비교표

### 실행 모드

| 기능 | rlm-skill-win | BowTiedSwan | brainqub3 |
|------|:-------------:|:-----------:|:---------:|
| Mode A: Parallel | ✅ | ✅ | ❌ |
| Mode B: Sequential | ✅ | ❌ | ✅ (유일) |
| Mode C: Direct Tool | ✅ | ❌ | ❌ |
| Mode D: Hybrid Semantic | 🔜 계획 | ❌ | ✅ (기본) |

### 플랫폼 지원

| 기능 | rlm-skill-win | BowTiedSwan | brainqub3 |
|------|:-------------:|:-----------:|:---------:|
| Windows Native | ✅ 최적화 | ⚠️ 불안정 | ✅ |
| Linux/Mac | ✅ | ✅ | ✅ |
| WSL 가이드 | ✅ | ❌ | ❌ |
| Windows 설치 스크립트 | ✅ BAT+PS1 | ❌ | ❌ |

### 기술적 특성

| 기능 | rlm-skill-win | BowTiedSwan | brainqub3 |
|------|:-------------:|:-----------:|:---------:|
| UTF-8 한국어 | ✅ | ❌ | ❌ |
| 상태 관리 | 🔜 계획 | ❌ | ✅ REPL |
| Sub-LLM 위임 | 🔜 계획 | ❌ | ✅ Haiku |
| 에러 복구 문서 | ✅ 상세 | ❌ | ❌ |
| SDK 이슈 대응 | ✅ #6836 | ❌ | N/A |

### 설치 복잡도

| 항목 | rlm-skill-win | BowTiedSwan | brainqub3 |
|------|:-------------:|:-----------:|:---------:|
| 필요 파일 수 | 2개 | 2개 | 3개+ |
| 디렉토리 구조 | skills/ | skills/ | skills/ + agents/ |
| 외부 의존성 | 없음 | 없음 | Python REPL |
| 설치 시간 | ~1분 | ~1분 | ~5분 |

---

## 비교우위 매트릭스

### rlm-skill-win 강점 (녹색)

| 영역 | 우위 내용 | vs BowTiedSwan | vs brainqub3 |
|------|----------|:--------------:|:------------:|
| Windows 안정성 | SDK 이슈 우회 | 🟢 +++ | 🟢 ++ |
| 모드 다양성 | 3가지 모드 | 🟢 +++ | 🟢 +++ |
| 비용 효율 | Mode C 무료 | 🟢 ++ | 🟢 +++ |
| 설치 편의성 | 스크립트 제공 | 🟢 ++ | 🟢 ++ |
| 한국어 지원 | UTF-8 | 🟢 +++ | 🟢 +++ |
| 에러 복구 | 상세 문서 | 🟢 +++ | 🟢 ++ |

### rlm-skill-win 약점 (적색)

| 영역 | 열위 내용 | vs BowTiedSwan | vs brainqub3 |
|------|----------|:--------------:|:------------:|
| 의미 분석 | Sub-LLM 없음 | 🟡 동등 | 🔴 --- |
| 상태 관리 | 무상태 | 🟡 동등 | 🔴 -- |
| 청크 간 컨텍스트 | 공유 불가 | 🟡 동등 | 🔴 -- |

---

## 시나리오별 최적 선택

| 시나리오 | 최적 도구 | 이유 |
|----------|----------|------|
| **단순 패턴 검색** (<50 파일) | **rlm-skill-win Mode C** ⭐ | 가장 빠르고 무료 |
| **Windows에서 대규모 분석** | **rlm-skill-win Mode B** | 안정적 |
| **Linux에서 최고 속도** | **rlm-skill-win Mode A** | 병렬 처리 |
| **복잡한 의미 분석** | brainqub3 | Sub-LLM 지원 |
| **다단계 상태 유지 분석** | brainqub3 | REPL 상태 관리 |
| **비용 최소화** | **rlm-skill-win Mode C** ⭐ | LLM 호출 0 |
| **한국어 프로젝트** | **rlm-skill-win** ⭐ | UTF-8 지원 |

---

## 비용 비교 (100 파일 분석)

| 방식 | API 호출 | 예상 비용 |
|------|----------|----------|
| rlm-skill-win Mode C | 0 | $0 |
| rlm-skill-win Mode B | 100 (Sequential) | ~$X |
| BowTiedSwan Mode A | 100 (Parallel) | ~$X |
| brainqub3 | 100 × Haiku | ~$0.025 |
| **rlm-skill-win Mode D** (계획) | 20 × Haiku | ~$0.005 |

### Mode D 구현 시 예상 비용 절감

```
brainqub3 방식:     100 파일 × Haiku = 100회 호출
Mode D (계획):      Grep 필터 → 20 파일 × Haiku = 20회 호출
                    비용 80% 절감 ⭐
```

---

## 경쟁력 확보 전략

### 단기 (v1.1)
- [x] Mode A/B/C 구현
- [x] Windows SDK 이슈 대응
- [x] 에러 복구 문서화
- [ ] Mode D 기본 구현

### 중기 (v1.2)
- [ ] 상태 관리 기능
- [ ] Sub-LLM 에이전트 (rlm-analyzer)
- [ ] 캐시 시스템

### 장기 (v2.0)
- [ ] AST 기반 청크 분할
- [ ] 다국어 지원 확장
- [ ] 분석 결과 시각화

---

## 결론

### 현재 상태
| 영역 | rlm-skill-win 위치 |
|------|-------------------|
| Windows 지원 | 🥇 1위 |
| 모드 다양성 | 🥇 1위 |
| 비용 효율 | 🥇 1위 |
| 의미 분석 | 🥉 3위 |
| 상태 관리 | 🥉 3위 |

### Mode D 구현 후 예상
| 영역 | rlm-skill-win 위치 |
|------|-------------------|
| Windows 지원 | 🥇 1위 |
| 모드 다양성 | 🥇 1위 |
| 비용 효율 | 🥇 1위 |
| **의미 분석** | **🥇 1위** |
| **상태 관리** | **🥈 2위** |

**Mode D 구현으로 모든 영역에서 경쟁력 확보 가능**

---

## 참고 링크

- [BowTiedSwan/rlm-skill](https://github.com/BowTiedSwan/rlm-skill)
- [brainqub3/claude_code_RLM](https://github.com/brainqub3/claude_code_RLM)
- [Claude Code SDK Issue #6836](https://github.com/anthropics/claude-code/issues/6836)
- [ArXiv 2512.24601 - RLM Paper](https://arxiv.org/abs/2512.24601)

---

**Document Version:** 1.0
**Created:** 2026-01-22
**Author:** Claude Opus 4.5
