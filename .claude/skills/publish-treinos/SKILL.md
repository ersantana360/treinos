---
name: publish-treinos
description: Update the owner's personal training data (public/data/me.json) that powers the read-only /me page, then commit, push to GitHub, and deploy to Cloudflare so it syncs to every device. Use when the user says they did a workout, wants to add/change a routine or the weekly schedule, sends an export from the app, or asks to update/publish "my treino".
---

# publish-treinos

`/me` on the deployed site renders **`public/data/me.json`** read-only. This skill
updates that file and publishes it.

## Steps

1. **Read** `public/data/me.json` to see the current routines, sessions, and schedule.

2. **Apply the change** the user asked for:
   - *Logged a workout* → append a session:
     `{ "id": "<unique>", "date": "YYYY-MM-DD", "name": "<routine or label>",
        "exercises": [ { "name","sets","reps","weight","unit":"kg" } ] }`
     (Ask for weights if not given; sessions are what feed the progression chart.)
   - *New / changed routine* → edit the `routines` array. Keep each routine's
     `id` stable because `schedule` points at it. `exercises` here have only
     `name`, `sets`, `reps` (no weight).
   - *Weekly plan* → edit `schedule`, keys `"0"`–`"6"` (Sun..Sat) → routine `id`.
   - *User pasted/sent an app export* → it's already in this shape; merge or
     replace the arrays as appropriate.

3. **Validate**: `node -e "JSON.parse(require('fs').readFileSync('public/data/me.json','utf8'))"`.

4. **Publish**: `./scripts/publish.sh "log <date> <workout>"` (commits, pushes,
   and `wrangler deploy`s). Confirm the deploy succeeded and share the `/me` URL.

## Notes
- Never put secrets in the repo (it's public). `/me` is read-only by design.
- Don't touch `localStorage` logic — that's the separate `/` per-device app.
