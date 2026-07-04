# CLAUDE.md — treinos

Single-file workout diary (pt-BR, terminal theme) hosted as a static Cloudflare
Worker. No build step, no backend, no secrets.

## Layout

```
public/index.html      the entire app (HTML + CSS + vanilla JS)
public/data/me.json    the OWNER's training data — source of truth for /me
wrangler.jsonc         Cloudflare Workers static-assets config
scripts/publish.sh     commit + push + deploy in one step
.claude/skills/publish-treinos/   skill for updating the owner's data
```

## Two runtime modes (same file, chosen by URL path)

- **`/`** — normal app. Data lives in the browser's `localStorage` (per-device).
  Anyone can use it with their own data. Full editing (log sessions, build
  routines, set the weekly schedule).
- **`/me`** — read-only view of the OWNER's data, fetched from `/data/me.json`
  (the committed file), so it's identical on every device. All mutating controls
  are hidden. Controlled by `const ME_MODE = /^\/me(\/|$)/.test(location.pathname)`.

`/me` never writes. To change what `/me` shows, edit `public/data/me.json` and
publish (see below). The app's own **⇧ exportar** produces a file in exactly the
`me.json` shape, so the owner can export from `/` and hand it over to drop in.

## Data shape (`me.json`)

```json
{ "routines": [ { "id","name","exercises":[{"name","sets","reps"}] } ],
  "sessions": [ { "id","date":"YYYY-MM-DD","name","exercises":[{"name","sets","reps","weight","unit"}] } ],
  "schedule": { "<0-6 = Sun..Sat>": "<routine id>" } }
```

Keep routine `id`s stable — the `schedule` references them.

## Updating the owner's training (the common task)

1. Edit `public/data/me.json` (add a session the owner reports, tweak routines,
   change the weekly `schedule`). If they send an export from the app, replace
   the relevant arrays with it.
2. Run `./scripts/publish.sh "message"` — commits, pushes to GitHub, and
   `wrangler deploy`s. `/me` reflects it on all devices after the deploy.

Or invoke the **publish-treinos** skill, which does exactly this.

## Deploy / dev

```bash
wrangler deploy        # https://treinos.neves-erick.workers.dev
wrangler dev           # local preview
```

Verify before pushing: extract the `<script>` and `node --check` it; the repo has
no test runner but the logic (import/normalize/schedule) is pure and easy to
exercise in a small Node VM harness.
