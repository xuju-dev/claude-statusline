# Claude Code Status Line

A compact, color-coded status line for [Claude Code](https://claude.com/claude-code)
showing your model, context usage, and subscription usage windows:

```
Opus 5.5 (medium) | ctx (6%) | 5h (3%) 1h58m | 7d (45%) 3d13h
```
It looks like this in the CLI:


<img width="674" height="145" alt="image" src="https://github.com/user-attachments/assets/58b10a8a-d6c8-407e-bd5c-ce77df2f59b3" />


| Segment | Meaning |
| --- | --- |
| `Opus 5.5 (medium)` | Current model and effort level |
| `ctx (6%)` | Context window used |
| `5h (3%) 1h58m` | 5-hour usage window: % used, time until reset |
| `7d (45%) 3d13h` | 7-day usage window: % used, time until reset |

Percentages are green below 50%, yellow from 50-79%, and red at 80%+.
All values come from the live data Claude Code sends to the status line.

## Install

Requires `jq` (`brew install jq` or `apt install jq`).

```bash
git clone https://github.com/xuju-dev/claude-statusline
cd claude-statusline
./install.sh
```

This copies `statusline.sh` to `~/.claude/` and adds this to `~/.claude/settings.json`:

```json
"statusLine": { "type": "command", "command": "~/.claude/statusline.sh", "padding": 0 }
```

Send a message in Claude Code (or restart it) and the line appears.

## Or have Claude build it

Paste the contents of [PROMPT.md](PROMPT.md) into Claude Code.

## Notes

- The 5h/7d segments only appear for Pro/Max subscription logins; missing data is skipped silently.
- Colors are plain ANSI codes at the top of `statusline.sh`, so they're easy to change.
- Debugging: run Claude Code with `CLAUDE_STATUSLINE_DEBUG=1` to save the last input JSON to
  `~/.claude/statusline-last-input.json`.
- Test manually:
  ```bash
  echo '{"model":{"display_name":"Opus 5.5"},"effort":{"level":"medium"},"context_window":{"used_percentage":6},"rate_limits":{"five_hour":{"used_percentage":3,"resets_at":'$(( $(date +%s)+7110 ))'}}}' | ./statusline.sh
  ```

## License

MIT, see [LICENSE](LICENSE).
