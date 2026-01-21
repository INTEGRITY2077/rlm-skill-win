# RLM Skill Windows - Development Roadmap

> Mode D (Hybrid Semantic Analysis) 기획서

## 현재 상태 (v1.0)

### 지원 모드
| 모드 | 설명 | 상태 |
|------|------|------|
| Mode A | Parallel Agent | ✅ 구현 (Linux/WSL only) |
| Mode B | Sequential Agent | ✅ 구현 |
| Mode C | Direct Tool | ✅ 구현 |
| **Mode D** | **Hybrid Semantic** | 🔴 미구현 |

---

## Mode D: Hybrid Semantic Analysis

### 목적
복잡한 의미 분석이 필요한 경우, Mode C의 빠른 필터링과 Sub-LLM의 깊은 분석을 결합하여 비용 효율적인 의미 분석 제공.

### 아키텍처

```
┌─────────────────────────────────────────────────────┐
│  Mode D: Hybrid Semantic                            │
├─────────────────────────────────────────────────────┤
│  Phase 1: Fast Filter (Mode C)                      │
│  └─ Grep/Glob으로 후보 파일 빠르게 식별             │
│  └─ 100개 파일 → 20개 후보 (80% 절감)              │
├─────────────────────────────────────────────────────┤
│  Phase 2: Semantic Analysis (Sub-LLM)               │
│  └─ rlm-analyzer 에이전트 (Haiku 모델)             │
│  └─ 각 청크의 의미 분석 및 구조화된 출력           │
├─────────────────────────────────────────────────────┤
│  Phase 3: State Cache                               │
│  └─ 분석 결과 .rlm_state.json 저장                  │
│  └─ 재분석 시 캐시 활용으로 비용 절감              │
├─────────────────────────────────────────────────────┤
│  Phase 4: Synthesis                                 │
│  └─ Root LLM이 Sub-LLM 결과 종합                   │
│  └─ 최종 답변 생성                                 │
└─────────────────────────────────────────────────────┘
```

### 비용 효율성

| 시나리오 | 기존 방식 | Mode D |
|----------|-----------|--------|
| 100 파일 분석 | 100 × Haiku | 20 × Haiku |
| 1차 필터 비용 | LLM 호출 | Grep (무료) |
| 재분석 비용 | 동일 | 캐시 히트 (무료) |
| **총 비용** | **100%** | **~20%** |

---

## 구현 계획

### Phase 1: Sub-agent 정의 (난이도: 쉬움)

**파일:** `.claude/agents/rlm-analyzer.md`

```markdown
---
name: rlm-analyzer
model: haiku
description: Code chunk semantic analyzer for RLM
---

You are a code analysis agent. Analyze the given code chunk and extract:

1. **Functions/Classes**: Names, signatures, purposes
2. **Dependencies**: Imports, external calls
3. **Patterns**: Design patterns, anti-patterns
4. **Issues**: Potential bugs, security concerns
5. **Relationships**: How this connects to other code

Output format: Structured JSON only.

Example output:
{
  "file": "src/api/users.ts",
  "functions": [
    {"name": "getUser", "params": ["id: string"], "returns": "User | null"}
  ],
  "dependencies": ["prisma", "zod"],
  "issues": ["No input validation on line 42"],
  "relationships": ["Called by AuthController"]
}
```

### Phase 2: SKILL.md Mode D 섹션 추가 (난이도: 쉬움)

```markdown
#### Mode D: Hybrid Semantic (복잡한 의미 분석)

**When to use:**
- 단순 패턴 매칭으로 불충분한 경우
- 코드 의미 이해가 필요한 경우
- 리팩토링 영향 분석
- 의존성 추적

**Workflow:**
1. **Filter**: Mode C로 후보 파일 식별
2. **Analyze**: rlm-analyzer(Haiku)에 청크 위임
3. **Cache**: 결과를 .rlm_state.json에 저장
4. **Synthesize**: 분석 결과 종합

**Example:**
Task(subagent_type="rlm-analyzer", prompt="Analyze this chunk: {code}")
```

### Phase 3: rlm.py 상태 관리 (난이도: 중간)

```python
import hashlib

class RLMContext:
    def __init__(self):
        self.state_file = Path(".rlm_state.json")
        self.analysis_cache = {}

    def get_file_hash(self, filepath: str) -> str:
        """파일 변경 감지용 해시"""
        content = Path(filepath).read_text()
        return hashlib.md5(content.encode()).hexdigest()

    def save_state(self):
        """분석 결과 저장"""
        state = {
            "version": "1.0",
            "timestamp": datetime.now().isoformat(),
            "cache": self.analysis_cache
        }
        with open(self.state_file, 'w', encoding='utf-8') as f:
            json.dump(state, f, indent=2, ensure_ascii=False)

    def load_state(self) -> bool:
        """이전 분석 결과 로드"""
        if not self.state_file.exists():
            return False
        with open(self.state_file, encoding='utf-8') as f:
            state = json.load(f)
            self.analysis_cache = state.get("cache", {})
        return True

    def get_cached_analysis(self, filepath: str) -> dict | None:
        """캐시된 분석 결과 조회 (파일 변경 시 무효화)"""
        current_hash = self.get_file_hash(filepath)
        cached = self.analysis_cache.get(filepath)
        if cached and cached.get("hash") == current_hash:
            return cached.get("analysis")
        return None

    def set_cached_analysis(self, filepath: str, analysis: dict):
        """분석 결과 캐싱"""
        self.analysis_cache[filepath] = {
            "hash": self.get_file_hash(filepath),
            "analysis": analysis,
            "timestamp": datetime.now().isoformat()
        }
```

### Phase 4: AST 기반 청크 분할 (난이도: 어려움, 선택적)

```python
import ast

def get_semantic_chunks(self, filepath: str) -> list[dict]:
    """함수/클래스 단위로 의미있는 청크 분할"""
    content = Path(filepath).read_text()

    if filepath.endswith('.py'):
        return self._chunk_python(content)
    elif filepath.endswith(('.ts', '.tsx', '.js', '.jsx')):
        return self._chunk_typescript(content)
    else:
        return self._chunk_by_size(content)

def _chunk_python(self, content: str) -> list[dict]:
    """Python AST 기반 분할"""
    tree = ast.parse(content)
    chunks = []
    for node in ast.walk(tree):
        if isinstance(node, (ast.FunctionDef, ast.ClassDef)):
            chunks.append({
                "type": type(node).__name__,
                "name": node.name,
                "start_line": node.lineno,
                "end_line": node.end_lineno,
                "content": ast.get_source_segment(content, node)
            })
    return chunks
```

---

## 구현 우선순위

| 순위 | 항목 | 난이도 | 효과 | 예상 시간 |
|------|------|--------|------|----------|
| 1 | rlm-analyzer.md 에이전트 | 쉬움 | ⭐⭐⭐ | 30분 |
| 2 | SKILL.md Mode D 문서 | 쉬움 | ⭐⭐ | 30분 |
| 3 | rlm.py 상태 관리 | 중간 | ⭐⭐⭐ | 2시간 |
| 4 | AST 기반 청크 분할 | 어려움 | ⭐⭐ | 4시간+ |

---

## 마일스톤

### v1.1 (단기)
- [ ] rlm-analyzer.md 에이전트 정의
- [ ] SKILL.md Mode D 섹션 추가
- [ ] README.md 업데이트

### v1.2 (중기)
- [ ] rlm.py 상태 관리 기능
- [ ] 캐시 무효화 로직
- [ ] CLI에 `state` 명령 추가

### v2.0 (장기)
- [ ] AST 기반 청크 분할 (Python)
- [ ] TypeScript/JavaScript 지원
- [ ] 분석 결과 시각화

---

## 참고

- **brainqub3/claude_code_RLM**: Sub-LLM 패턴 참조
- **BowTiedSwan/rlm-skill**: 원본 RLM 구현
- **Claude Code SDK Issue #6836**: 병렬 처리 제한 사항

---

**Document Version:** 1.0
**Created:** 2026-01-22
**Author:** Claude Opus 4.5
