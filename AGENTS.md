# Roblox project review rules

- Treat all client input as untrusted.
- Flag any RemoteEvent or RemoteFunction usage without strict server-side validation.
- Prioritize economy exploits, duplicate rewards, and save-data corruption risks.
- Treat repeated event connections, infinite loops, and per-frame expensive work as high priority.
- Prefer minimal, high-confidence fixes.
- Do not refactor unrelated code.
- For Lua modules, check initialization order, circular requires, and nil access risks.
- For gameplay systems, prioritize bugs affecting rewards, save/load, purchases, leaderboards, pets, vehicles, and race state.