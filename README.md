# udayan's codex plugins

## learn

agents repeat mistakes. yours, and their own.

you spend an hour discovering the deploy needs a manual promote. or that the test suite goes green on PRs that never built. the session ends, the lesson evaporates. next week a fresh agent burns the same hour on the same pothole.

`$learn` fixes the leak.

run it at the end of a session and it replays what happened, then drafts the lessons worth keeping into your project's `learnings.md`. you review every line before anything is written.

it is picky about what counts as a learning:

- sequence errors: we did X before Y when Y should have come first
- scoping errors: something got included or excluded for the wrong reason
- assumption errors: we assumed X, reality was Y, and we could have checked earlier
- validated approaches: the non-obvious thing that worked, worth repeating
- known gaps: the unfinished edges the next person would waste time rediscovering

a missing import is not a learning. jumping to fixes before reading the full system is. the skill writes process, not changelogs.

## when to run it

- after a debugging session where the fix took 3 hours instead of 20 minutes
- after shipping a feature where the plan changed halfway through
- before handing a repo to a teammate or a fresh agent
- the second time you catch the same class of mistake

each entry compounds. agents read `learnings.md` at the start of the next session and skip the potholes you already paid for.

## install

run the one-command installer:

```sh
curl -fsSL https://raw.githubusercontent.com/udayangx/codex-plugins/main/install.sh | sh
```

or paste the manual setup into codex:

> run `codex plugin marketplace add udayangx/codex-plugins` then `codex plugin add learn@udayan`. then copy `prompts/learn.md` from the marketplace root shown by `codex plugin list` to `~/.codex/prompts/learn.md`.

restart codex. invoke with `$learn` or `/learn`, with an optional focus area:

```
$learn
$learn the deploy pipeline
```

## updating

```sh
codex plugin marketplace upgrade
```

## adding a plugin

create `plugins/<name>/` with `.codex-plugin/plugin.json` and `skills/<name>/SKILL.md` (plus an optional `skills/<name>/agents/openai.yaml`), then append an entry to `.agents/plugins/marketplace.json`. users pick it up with `codex plugin marketplace upgrade` then `codex plugin add <name>@udayan`.
