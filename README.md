# Udayan's Codex Plugins

## Install

Paste into Codex:

> Run `codex plugin marketplace add udayangx/codex-plugins` then `codex plugin add learn@udayan`

Restart Codex, then invoke the skill with `$learn`.

**Optional** — to also get `/learn` in the slash popup, copy [`prompts/learn.md`](prompts/learn.md) from this repo to `~/.codex/prompts/learn.md`.

## Plugins

| Plugin | What it does |
| --- | --- |
| `learn` | End-of-session `$learn` — drafts reusable process learnings for your review before writing to the project's `learnings.md`. |

## Updating

```sh
codex plugin marketplace upgrade
```

## Adding a plugin

Create `plugins/<name>/` with `.codex-plugin/plugin.json` + `skills/<name>/SKILL.md` (+ optional `skills/<name>/agents/openai.yaml`), append an entry to `.agents/plugins/marketplace.json`. Users get it with `codex plugin marketplace upgrade` then `codex plugin add <name>@udayan`.
