# ts_oxLogs

Discord logging for `ox_inventory` events with optional dupe detection and admin removal tracking.

## Features
- Drop, pickup, give, stash, and create item logs
- RemoveItem logs with admin context and target inventory details
- Dupe heuristic with optional auto-blacklist and kick
- ESX player context (identifier, job/grade, group)
- Optional IP logging with masking support

## Requirements
- `ox_inventory`
- `es_extended` (optional but recommended for ESX fields and command permissions)
- `oxmysql` is referenced in `fxmanifest.lua` but not required by this resource

## Installation
1) Place `ts_oxLogs` in your resources folder
2) Add to `server.cfg`:
   ```
   ensure ts_oxLogs
   ```
3) Configure `config.lua` webhooks and options
4) Restart the server

## Configuration
See `docs/CONFIGURATION.md` for the full option list and examples.

## Webhooks
See `docs/WEBHOOKS.md` for the event-to-webhook mapping and embed details.

## Commands
- `/removeitem <id> <item> <count>`
  - Disabled by default; enable in `Config.RemoveCommand`
  - Requires ESX group permission
  - Logs a removal embed and then calls `exports.ox_inventory:RemoveItem`

## Notes
- If you already have a `/removeitem` command in another resource, rename or disable one to avoid conflicts.
- This resource is server-side only; no client scripts are required.
