"""
RLM Engine - Recursive Language Model Helper Script
Windows-compatible version with UTF-8 support

Usage:
    python rlm.py scan              # Scan and index files
    python rlm.py peek "query"      # Search for pattern
    python rlm.py chunk --pattern   # Split files into chunks
"""

import os
import sys
import glob
import json
import math
from pathlib import Path
from typing import List, Dict, Any

# Windows compatibility: ensure UTF-8 output
if sys.platform == 'win32':
    sys.stdout.reconfigure(encoding='utf-8')


class RLMContext:
    def __init__(self, root_dir: str = "."):
        self.root = Path(root_dir).resolve()
        self.index: Dict[str, str] = {}
        self.chunk_size = 5000
        # Common excludes for both Windows and Unix
        self.excludes = ['.git', '__pycache__', 'node_modules', '.next', 'dist', 'build', '.cache']

    def load_context(self, pattern: str = "**/*", recursive: bool = True):
        files = glob.glob(str(self.root / pattern), recursive=recursive)
        loaded_count = 0
        skipped_count = 0
        for f in files:
            path = Path(f)
            # Normalize path for cross-platform comparison
            path_str = str(path).replace('\\', '/')
            if path.is_file() and not any(exc in path_str for exc in self.excludes):
                try:
                    self.index[str(path)] = path.read_text(encoding='utf-8', errors='ignore')
                    loaded_count += 1
                except Exception as e:
                    skipped_count += 1
        return f"RLM: Loaded {loaded_count} files into hidden context. Skipped {skipped_count}. Total size: {sum(len(c) for c in self.index.values())} chars."

    def peek(self, query: str, context_window: int = 200) -> List[str]:
        results = []
        for path, content in self.index.items():
            if query in content:
                start = 0
                while True:
                    idx = content.find(query, start)
                    if idx == -1:
                        break

                    snippet_start = max(0, idx - context_window)
                    snippet_end = min(len(content), idx + len(query) + context_window)
                    snippet = content[snippet_start:snippet_end]
                    results.append(f"[{path}]: ...{snippet}...")
                    start = idx + 1
        return results[:20]

    def get_chunks(self, file_pattern: str = None) -> List[Dict[str, Any]]:
        chunks = []
        targets = [f for f in self.index.keys() if (not file_pattern or file_pattern in f)]

        for path in targets:
            content = self.index[path]
            total_chunks = math.ceil(len(content) / self.chunk_size)
            for i in range(total_chunks):
                start = i * self.chunk_size
                end = min((i + 1) * self.chunk_size, len(content))
                chunks.append({
                    "source": path,
                    "chunk_id": i,
                    "content": content[start:end]
                })
        return chunks


if __name__ == "__main__":
    import argparse
    parser = argparse.ArgumentParser(description="RLM Engine - Recursive Language Model Helper")
    subparsers = parser.add_subparsers(dest="command")

    load_parser = subparsers.add_parser("scan", help="Scan and index files in current directory")
    load_parser.add_argument("--path", default=".", help="Root directory to scan")

    peek_parser = subparsers.add_parser("peek", help="Search for a pattern in indexed files")
    peek_parser.add_argument("query", help="Pattern to search for")

    chunk_parser = subparsers.add_parser("chunk", help="Split files into chunks for parallel processing")
    chunk_parser.add_argument("--pattern", default=None, help="File pattern filter (e.g., *.log)")

    args = parser.parse_args()

    if not args.command:
        parser.print_help()
        sys.exit(0)

    ctx = RLMContext()
    ctx.load_context()

    if args.command == "scan":
        print(ctx.load_context())
    elif args.command == "peek":
        results = ctx.peek(args.query)
        print(json.dumps(results, indent=2, ensure_ascii=False))
    elif args.command == "chunk":
        chunks = ctx.get_chunks(args.pattern)
        print(json.dumps(chunks, ensure_ascii=False))
