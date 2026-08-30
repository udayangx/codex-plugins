# Udayan's Codex Plugins

## Install

Paste into Codex:

> Run `codex plugin marketplace add udayangx/codex-plugins` then `codex plugin add learn@udayan`. Then copy `prompts/learn.md` from the marketplace root shown by `codex plugin list` to `~/.codex/prompts/learn.md`.

Restart Codex, then invoke the skill with `$learn` or `/learn`.

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
