# GrowthX Codex Plugins

A Codex plugin marketplace for GrowthX builders. Add it once and install any plugin listed here.

## Install (one prompt)

Paste this into a Codex session:

> Set up the GrowthX learn plugin: run `codex plugin marketplace add GrowthX-Club/codex-plugins` and then `codex plugin add learn@growthx`. Then create `~/.codex/prompts/learn.md` with exactly this content:
>
> ```
> ---
> description: Draft end-of-session process learnings for review (runs the learn skill)
> argument-hint: [optional focus area]
> ---
>
> Use the $learn skill: locate the installed learn plugin's skills/learn/SKILL.md and follow it exactly to draft this session's reusable process learnings for my review. Do not write any files until I approve. Focus area (may be empty): $ARGUMENTS
> ```
>
> Confirm the plugin shows as installed with `codex plugin list`.

Or run the two commands yourself:

```sh
codex plugin marketplace add GrowthX-Club/codex-plugins
codex plugin add learn@growthx
```

The `~/.codex/prompts/learn.md` shim is optional — it makes `/learn` appear in the slash popup. The skill itself is always invocable as `$learn` in a fresh Codex session after install.

## Plugins

| Plugin | What it does |
| --- | --- |
| `learn` | End-of-session `$learn` — replays the session and drafts reusable process learnings (sequence, scoping, and assumption errors; validated approaches; known gaps) for your review before writing to the project's `learnings.md`. |

## Updating

```sh
codex plugin marketplace upgrade
```

## Repo layout

```
.agents/plugins/marketplace.json   # marketplace manifest (name: growthx)
plugins/<name>/
  .codex-plugin/plugin.json        # plugin manifest
  skills/<name>/SKILL.md           # the skill itself
  skills/<name>/agents/openai.yaml # Codex-facing interface + invocation policy
```

To add a new plugin: create `plugins/<name>/` following the layout above, append an entry to `marketplace.json`, bump nothing else. Builders pick it up with `codex plugin marketplace upgrade` then `codex plugin add <name>@growthx`.
