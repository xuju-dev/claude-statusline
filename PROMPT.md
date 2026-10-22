# Prompt: build the status line with Claude Code

Paste this into Claude Code to recreate the status line from scratch.

---

Build me a Claude Code status line and enable it in `~/.claude/settings.json`
(keep my existing settings).

It should render one line like this:

    Opus 5.5 (medium) | ctx (6%) | 5h (3%) 1h58m | 7d (45%) 3d13h

- Model display name, then the effort level in parentheses.
- `ctx (N%)`: context window used.
- `5h (N%) <time>` and `7d (N%) <time>`: usage in the 5-hour and 7-day
  rate-limit windows, followed by a countdown to reset (`3d13h`, `1h58m`, `12m`).
- Use real data only. Claude Code pipes JSON to the script on stdin; read
  `model.display_name`, `effort.level`, `context_window.used_percentage`, and
  `rate_limits.{five_hour,seven_day}.{used_percentage,resets_at}`. Before
  writing the parsing, check the actual JSON by dumping stdin to a file once.
- Skip any segment whose data is missing (rate limits only exist for
  subscription logins). Never print errors.

Style:
- Model name bold cyan, effort magenta.
- Labels, `|` separators and countdowns in bright white (`\e[97m`).
- Percentages colored: green < 50%, yellow 50-79%, red >= 80%.

Implementation: a single bash script at `~/.claude/statusline.sh` using `jq`,
working on both macOS and Linux (reset time may be epoch seconds, milliseconds
or ISO-8601). Set `statusLine` to `{"type":"command","command":"~/.claude/statusline.sh","padding":0}`.
Test it with sample JSON, including a case with 62% and 91% to confirm colors.
