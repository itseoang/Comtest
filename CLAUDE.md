# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Repository Status

This repository ("Comtest" — Company Test) is in an **early/empty state**. It currently contains only:

- `README.md` — single-line description
- `LICENSE` — Apache 2.0
- `.gitignore` — standard Python ignore patterns
- `test.py` — a placeholder file with non-executable content (`Test.py`, `/**/`, `import * 4421`); this is **not valid Python** and should not be treated as a working module

There is no source tree, no build system, no test suite, no dependency manifest (no `pyproject.toml`, `setup.py`, `requirements.txt`, etc.), and no CI configuration yet.

## Implications for Working in This Repo

- **Do not invent architecture.** Until real code lands, there is no module layout, framework choice, or convention to preserve. Ask the user what they want to build before scaffolding.
- **`test.py` is not a real test.** Do not run it, import from it, or model new code after it. Treat it as a stub to be replaced.
- **The `.gitignore` signals Python.** Python is the likely intended language, but no version, package manager (pip / poetry / uv / pipenv), or runtime has been chosen — confirm with the user before introducing one.
- **No build/lint/test commands exist yet.** When the user adds tooling, update this file with the actual invocations.

## Branch Convention

Active development for AI-assisted changes happens on the branch `claude/add-claude-documentation-cWqEC` (per task instructions). Push only to the branch the user has authorized for the current task.
