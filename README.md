# ~/treinos

A single-file workout diary (terminal-themed, pt-BR) hosted as a static
Cloudflare Worker. Plan your **training days**, log the sessions you actually do,
watch a per-exercise load-progression chart, and **import/export** everything as
JSON.

Live: https://treinos.neves-erick.workers.dev
Repo: https://github.com/ersantana360/treinos

## Two modes (same app, chosen by URL)

- **`/`** — the normal app. Data lives in your **browser's `localStorage`**
  (per-device, private). Anyone can use it with their own data.
- **`/me`** — a **read-only** view of the owner's data loaded from the committed
  file [`public/data/me.json`](public/data/me.json), so it looks identical on
  every device. No login, no backend. To change what it shows, edit `me.json`
  and publish (`./scripts/publish.sh`) — or export from the app and hand the file
  over. The **⇧ exportar** button produces a file in exactly the `me.json` shape.

## Two concepts: plan vs. log

- **Dias de treino (routines)** — the *plan*. Named days like "Leg Day" holding
  the exercises you intend to do (name · séries · reps, no weight). Build them
  once under **dias de treino → + nova rotina**. Before the gym you glance at the
  routine and know what to do.
- **Treinos (sessions)** — the *log*. What you actually did on a date, with real
  weights. This is what feeds the progression chart.

Hit **▶ iniciar treino** on a routine to start a session pre-filled with that
day's exercises — each weight is seeded with what you lifted **last time** for
that movement, so you just adjust and save. You can also log ad-hoc with
**+ novo treino**.

### Weekly schedule (semana)

The **semana** panel pins a routine (or *descanso*) to each weekday. The
**hoje** callout at the top then shows today's plan with a direct
**iniciar treino** button — so before the gym you see exactly what to do. The
schedule is stored under `schedule-data`, included in export/import (keyed by JS
weekday `0`=Sun…`6`=Sat), and self-heals: deleting a routine clears any day that
pointed at it.

## Storage

Data lives in the **browser's `localStorage`** (per-device, private). There is no
backend and no account — this is a personal log. To move it between devices, use
**exportar** on one and **importar** on the other. If `localStorage` is
unavailable (private mode), the app falls back to an in-memory store for the
current session and shows a warning banner.

## Import / export

- **exportar** downloads `treinos-YYYY-MM-DD.json` — a full backup.
- **importar** accepts a `.json` file *or* pasted JSON, in two modes:
  - **mesclar** (merge) — adds new sessions and updates existing ones. Matches on
    `id`; if a session has no `id`, it matches on `date` + `name` so re-importing
    the same data doesn't create duplicates.
  - **substituir** (replace) — wipes the log and loads only the imported data.

### JSON format (LLM-friendly)

An export contains `routines` (the plan) and/or `sessions` (the log). On import
you can paste a bare array (treated as sessions) or an object with either/both
keys. The parser is tolerant: `id` and `unit` are optional, numbers may be
strings, and dates accept `YYYY-MM-DD` or `DD/MM/YYYY`. In **replace** mode, only
the sections present in the payload are replaced (e.g. importing just `routines`
leaves your `sessions` untouched).

```json
{
  "app": "treinos",
  "version": 1,
  "routines": [
    {
      "name": "Leg Day",
      "exercises": [
        { "name": "Agachamento", "sets": 4, "reps": 12 }
      ]
    }
  ],
  "sessions": [
    {
      "date": "2026-07-04",
      "name": "Leg Day",
      "exercises": [
        { "name": "Agachamento", "sets": 4, "reps": 12, "weight": 20, "unit": "kg" }
      ]
    }
  ]
}
```

The import dialog has a **"copiar prompt p/ IA"** button that copies a ready-made
prompt (it asks the LLM for a training *split* → `routines`). Paste it into any
LLM, then paste the result back into the import box.

## Develop

```bash
npm install          # installs wrangler
npm run dev          # local preview at http://localhost:8787
```

## Deploy

```bash
npm run deploy       # wrangler deploy  -> https://treinos.<subdomain>.workers.dev
```

Requires `wrangler login` (Cloudflare account with Workers enabled).

## Layout

```
public/index.html    the entire app (HTML + CSS + JS)
wrangler.jsonc       Cloudflare Workers static-assets config
```
