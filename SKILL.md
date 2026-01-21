---
name: rlm
description: Process large codebases (>100 files) using the Recursive Language Model pattern. Treats code as an external environment, using parallel background agents to map-reduce complex tasks without context rot.
triggers:
  - "analyze codebase"
  - "scan all files"
  - "large repository"
  - "RLM"
  - "find usage of X across the project"
---

# Recursive Language Model (RLM) Skill

## Core Philosophy
**"Context is an external resource, not a local variable."**

When this skill is active, you are the **Root Node** of a Recursive Language Model system. Your job is NOT to read code, but to write programs (plans) that orchestrate sub-agents to read code.

## Platform Detection

| Platform | RLM Script Path | Parallel Mode |
|----------|-----------------|---------------|
| **Windows** | `python %USERPROFILE%\.claude\skills\rlm\rlm.py` | ⚠️ Sequential recommended |
| **Linux/Mac** | `python3 ~/.claude/skills/rlm/rlm.py` | ✅ Parallel OK |

**Windows Note**: Due to Claude Code SDK concurrent tool use limitations (Issue #6836), use **Sequential Mode** or **Direct Tool Mode** instead of parallel background_task.

## Protocol: The RLM Loop

### Phase 1: Choose Your Engine
Decide based on the nature of the data:

| Engine | Use Case | Tool |
|--------|----------|------|
| **Native Mode** | General codebase traversal, finding files, structure. | Glob, Grep tools (preferred) |
| **Strict Mode** | Dense data analysis (logs, CSVs, massive single files). | `python rlm.py` |

### Phase 2: Index & Filter (The "Peeking" Phase)
**Goal**: Identify relevant data without loading it.
1.  **Native**: Use `Glob` or `Grep` tools directly (NOT bash grep).
2.  **Strict**: Use `python rlm.py peek "query"`.
    *   *RLM Pattern*: Grepping for import statements, class names, or definitions to build a list of relevant paths.

### Phase 3: Map (The "Sub-Query" Phase)
**Goal**: Process chunks using fresh contexts.

#### Mode A: Parallel (Linux/Mac only, Claude Code v2.1.9+)
1.  **Divide**: Split the work into atomic units.
2.  **Spawn**: Use `Task` tool with `run_in_background: true` to launch parallel agents.
    *   *Constraint*: Launch 3-5 agents in parallel for broad tasks.
    *   *Prompting*: Give each agent ONE specific chunk or file path.

#### Mode B: Sequential (Windows / Fallback)
1.  **Divide**: Split the work into atomic units.
2.  **Execute**: Use `Task` tool **without** `run_in_background` sequentially.
    *   Process one agent at a time, collect result, then start next.
    *   Slower but avoids concurrent tool use errors.

#### Mode C: Direct Tool (Fastest, Recommended for <50 files)
1.  **Skip agents entirely**: Use Grep/Read tools directly in batches of 3-5.
2.  **Synthesize inline**: Process results as you go.
    *   Best for targeted searches where you know what to look for.

### Phase 4: Reduce & Synthesize (The "Aggregation" Phase)
**Goal**: Combine results into a coherent answer.
1.  **Collect**: Read the outputs from agents or direct tool calls.
2.  **Synthesize**: Look for patterns, consensus, or specific answers in the aggregated data.
3.  **Refine**: If the answer is incomplete, perform a second RLM recursion on the specific missing pieces.

## Critical Instructions

1.  **NEVER** use `cat *` or read more than 3-5 files into your main context at once.
2.  **Prefer Direct Tools** (Glob, Grep, Read) over bash commands.
3.  **On Windows**: Use Sequential Mode or Direct Tool Mode to avoid API Error 400.
4.  **Use `rlm.py`** for programmatic slicing of large files that Grep can't handle well.
5.  **Python is your Memory**: If you need to track state across 50 files, write a Python script to scan them and output a summary.

## Example Workflow: "Find all API endpoints and check for Auth"

**Wrong Way (Monolithic)**:
- `read src/api/routes.ts`
- `read src/api/users.ts`
- ... (Context fills up, reasoning degrades)

**RLM Way - Direct Tool Mode (Recommended)**:
1.  **Filter**: `Grep` tool with pattern `@Controller` -> Returns 20 files.
2.  **Map (batched)**:
    - Read 3-5 files at a time using parallel `Read` tool calls
    - Extract endpoints inline, add to running list
3.  **Reduce**: Compile final table, identify missing auth.

**RLM Way - Sequential Agent Mode (Windows)**:
1.  **Filter**: `Grep` tool -> Returns 20 files.
2.  **Map (sequential)**:
    - `Task(subagent_type="Explore", prompt="Read src/api/routes.ts. Extract endpoints.")` → wait → collect
    - `Task(subagent_type="Explore", prompt="Read src/api/users.ts. Extract endpoints.")` → wait → collect
    - ... (One at a time)
3.  **Reduce**: Compile all results.

## Recovery Mode & Error Handling

### If "API Error: 400 due to tool use concurrency" occurs:
1.  **Stop parallel execution immediately**
2.  **Switch to Sequential Mode or Direct Tool Mode**
3.  **Do NOT retry parallel** - the error will persist

### If background_task output files are empty:
1.  **Agent likely failed silently** - don't wait for it
2.  **Fall back to Direct Tool Mode**: Use Grep + Read tools directly
3.  **Or use Python scripting**: Write a script that scans files and outputs summary

### Iterative Python Fallback:
```python
# Example: Scan all .tsx files for a pattern
import glob
for f in glob.glob("**/*.tsx", recursive=True):
    content = open(f).read()
    if "targetPattern" in content:
        print(f"{f}: Found pattern at line {content[:content.find('targetPattern')].count(chr(10))+1}")
```

## Version Compatibility

| Claude Code Version | Parallel Background Tasks |
|---------------------|---------------------------|
| < v2.1.7 | ❌ Frequently fails |
| v2.1.7 - v2.1.8 | ⚠️ Partial fix |
| >= v2.1.9 | ✅ Fixed (orphan tool_result) |

Check version: `claude --version`
