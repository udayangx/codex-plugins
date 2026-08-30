---
name: learn
description: Draft end-of-session process learnings and validated approaches for the current project's learnings.md. Use when the user explicitly invokes $learn, optionally with a focus area.
---

# Session Learnings

Draft the learnings for this session and present them for review. Do not write any files yet. The user must be able to review, revise, and explicitly approve the proposed content before it is saved.

Before drafting, inspect the current conversation, relevant repository state, and the existing `learnings.md` at the repository root when present. If the user supplied a focus area, prioritize it without ignoring other material process learnings.

This is not a changelog. This is not a session recap. This is not a list of bugs you found.

## The core question

Before writing anything, ask yourself: **what did we do first, and what should we have done first?**

Every learning is a process problem. A missing import is not a learning — jumping to fixes before reading the full system is. A broken credential is not a learning — scoping by fix category instead of by goal is.

Technical details are *examples* that illustrate the process failure. They are never the learning itself.

## How to find learnings

Replay the session and look for:
- **Sequence errors:** We did X before Y, but Y should have come first
- **Scoping errors:** We included/excluded something for the wrong reason
- **Assumption errors:** We assumed X, reality was Y, and we could have checked earlier
- **Validated approaches:** We did something non-obvious that worked — worth repeating
- **Known gaps:** What's unfinished that someone continuing would waste time not knowing

## Format

When creating a new file, use a flat list with no top-level headings, categories, dates, or numbering. When updating an existing file, follow its established structure and style instead of forcing this default format.

Each entry follows this structure:

```
## [One-sentence principle about process]
### [Example context — why this matters, one line.]
- [Specific instance from this session]
- [Another instance]
```

`##` is the principle. `###` is the example context. `-` are specific instances. Every entry must have at least a `##` and `###`. Instances are optional if the `###` line is self-sufficient.

Known gaps go at the bottom after a `---` divider, under a single `### Known gaps` heading with `-` bullets.

**Include if:** the process mistake or validated approach could happen again on a completely different project.
**Exclude if:** it's a specific technical fact, a bug description, or only relevant to this codebase.

If multiple mistakes share a root cause, collapse them into one entry.

## Review flow

Present the draft with temporary item numbers so the user can say "drop 2" or "rewrite 3." Strip those review numbers when saving unless the destination file's existing convention uses numbering.

After explicit approval, merge the approved content into the project-root `learnings.md`; do not overwrite unrelated existing content. Re-read the resulting section to verify the merge.

If a proposed learning applies beyond this repository, identify it separately in the review draft as a cross-project candidate. Do not edit Codex memory directly. Only after the user explicitly approves the memory update, create one small ingestion note under `/Users/udayan/.codex/memories/extensions/ad_hoc/notes/` using the filename format `<timestamp>-<short-slug>.md`.

## Rules

- Every entry is about process (sequence, scoping, assumptions), not about technology
- Technical details appear only as supporting examples, never as standalone items
- Under 10 items for a small session. Up to 20 for a large one.
- Collapse entries that share one root cause.
- Preserve the destination file's established format when one exists.
