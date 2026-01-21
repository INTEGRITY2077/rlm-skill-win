# RLM Skill - Usage Examples

## Basic Examples

### 1. Track Props Flow

**Goal**: Track how a prop propagates through components

```
RLM: onResize prop이 전달되는 전체 경로를 추적해줘.
어디서 정의되고, 어떤 컴포넌트를 거쳐서 최종적으로 어디서 호출되는지
```

---

### 2. Find Component Dependencies

**Goal**: Find all files that use a specific component

```
analyze codebase: ResizeHandles 컴포넌트를 import하거나 사용하는
모든 파일을 찾아서 의존성 트리를 만들어줘
```

---

### 3. Type Validation

**Goal**: Verify TypeScript type usage across codebase

```
scan all files: CanvasLayer 타입을 사용하는 모든 변수와 함수를 찾아서
타입 정의와 일치하는지 확인해줘
```

---

### 4. Find Dead Code

**Goal**: Identify unused exports

```
RLM: components/admin/editor 폴더 내에서
export되었지만 import되지 않은 함수/컴포넌트를 모두 찾아줘
```

---

### 5. Log Analysis

**Goal**: Extract error patterns from large log files

```
large repository: logs/*.log 파일들을 분석해서
에러 메시지와 발생 빈도를 정리해줘
```

**Or use Python directly:**
```batch
cd C:\your-project
python %USERPROFILE%\.claude\skills\rlm\rlm.py peek "ERROR"
```

---

### 6. Performance Audit

**Goal**: Find React hooks with problematic dependencies

```
analyze codebase: useEffect나 useMemo에서 의존성 배열이
비어있거나 과도하게 큰 경우를 모두 찾아서 리스트업해줘
```

---

### 7. API Documentation

**Goal**: Map all API endpoints

```
scan all files: fetch, axios, api.get, api.post 등의 패턴을 찾아서
모든 API 엔드포인트 URL과 호출 위치를 정리해줘
```

---

### 8. Migration Prep

**Goal**: Find deprecated APIs before upgrading

```
RLM: React 18에서 deprecated된 API(UNSAFE_*, findDOMNode 등)를
사용하는 모든 코드를 찾아서 마이그레이션 가이드와 함께 정리해줘
```

---

### 9. Security Scan

**Goal**: Find potential XSS vulnerabilities

```
analyze codebase: innerHTML, dangerouslySetInnerHTML, eval() 사용을
모두 찾아서 보안 위험도와 함께 리포트해줘
```

---

### 10. Refactoring Analysis

**Goal**: Understand impact before refactoring

```
RLM: BlockEditorStore의 updateLayer 함수를 수정하면
영향받는 모든 컴포넌트를 찾아서 수정 범위를 예측해줘
```

---

## Python CLI Examples

### Scan TSX Files Only
```batch
cd C:\your-project
python %USERPROFILE%\.claude\skills\rlm\rlm.py scan --pattern "*.tsx"
```

### Search with Context
```batch
python %USERPROFILE%\.claude\skills\rlm\rlm.py peek "scaleFactor"
```

### Chunk Large Files
```batch
python %USERPROFILE%\.claude\skills\rlm\rlm.py chunk --pattern "*.log" > chunks.json
```

### Scan Specific Folder
```batch
cd C:\your-project\src\components
python %USERPROFILE%\.claude\skills\rlm\rlm.py scan --pattern "**/*.tsx"
```

---

## Advanced Tips

### Tip 1: Pipeline Pattern

Combine multiple commands:

```batch
REM Step 1: Find all TSX files
python rlm.py scan --pattern "*.tsx" > step1.json

REM Step 2: Filter for specific keyword
python rlm.py peek "scaleFactor" > step2.json

REM Step 3: Detailed analysis with Claude
REM "step2.json 결과를 바탕으로 각 파일의 scaleFactor 사용 패턴 분석해줘"
```

### Tip 2: Regex Patterns

Complex pattern search:

```
RLM: "onResize.*scaleFactor|scaleFactor.*onResize" 패턴을
정규식으로 검색해서 두 키워드가 함께 나타나는 곳을 찾아줘
```

### Tip 3: Progressive Exploration

Start broad, then narrow down:

```
1. "RLM: 전체 프로젝트에서 resize 관련 파일 찾아줘"
2. "방금 찾은 파일들 중 BlockLayerInteraction만 집중 분석해줘"
3. "BlockLayerInteraction의 handleResize 함수 로직을 자세히 설명해줘"
```

### Tip 4: Visualization

Request diagrams:

```
RLM: onResize 콜백 체인을 분석해서 Mermaid 플로우차트로 그려줘
```

---

## Performance Comparison

### Without RLM
```
Time: ~15 min
Context: 100% (exhausted)
Accuracy: Medium (fatigue errors)
Files: Sequential (30-50 limit)
```

### With RLM
```
Time: ~3 min
Context: 20% (efficient)
Accuracy: High (parallel minimizes errors)
Files: Parallel (100+ possible)
```

---

## Quick Start Checklist

- [ ] Install RLM Skill (`install-windows.bat`)
- [ ] Verify installation (`test-rlm.bat`)
- [ ] Check Python (`python --version`)
- [ ] First RLM command: `"RLM: 현재 프로젝트 구조 분석해줘"`
- [ ] Try one example above
- [ ] Apply to your project
