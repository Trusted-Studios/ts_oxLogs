# Configuration

All settings live in `config.lua`. Edit values to match your server and Discord webhooks.

## Webhooks
`Config.Webhooks` maps event types to Discord webhook URLs.

Keys used by the script:
- `drop`
- `pickup`
- `give`
- `stash`
- `dupe`
- `create`
- `remove`

Notes:
- Leave a webhook empty (`""`) to disable that log.
- `base` is present in the config but not used by the script.

## Discord Embed Settings
`Config.Discord` controls embed branding.

- `Username`: Webhook sender name
- `AvatarUrl`: Webhook avatar image URL
- `ServerName`: Embed author name
- `FooterText`: Embed footer text
- `FooterIcon`: Embed footer icon URL
- `AuthorIcon`: Embed author icon URL
- `UseFieldIcons`: Toggle emoji labels in fields

## Language and Translations
`Config.Locale` selects the active language (default `en`).

`Config.Translations` contains translation tables. You can add a new language by
adding a new key (e.g. `fr`) and copying the same structure as `en`.

Example:
```
Config.Locale = "fr"
Config.Translations.fr = {
    labels = { player = "Joueur", ... },
    embeds = { drop_title = "...", drop_desc = "...", ... },
    templates = { esx_info = "Identifier: `{identifier}`\\nJob: `{job}`\\nGroup: `{group}`", ... },
    messages = { no_permission = "Pas de permission.", ... }
}
```

## Colors
`Config.Colors` sets embed colors by event type. Values are hex integers, e.g. `0x2ecc71`.

## Privacy
`Config.Privacy` controls IP logging behavior.

- `LogIP`: Adds IP field to embeds when true
- `MaskIP`: Replaces the last octet with `xxx` when true

## Dupe Detection
`Config.Dupe` configures the dupe heuristic and blacklist.

- `Enabled`: Enable detection
- `ItemWhitelist`: When non-empty, only these items are checked
- `MaxSingleMoveDefault`: Threshold for single move amount
- `MaxSingleMoveByItem`: Per-item overrides
- `WindowSeconds`: Sliding time window in seconds
- `MaxActionsInWindow`: Max actions in the window before flagging
- `AutoBlacklist`: Auto-add to KVP blacklist when suspicious
- `KickOnBlacklist`: Kick if blacklisted
- `BlacklistReason`: Kick reason text
- `KvpKey`: KVP storage key
- `BlacklistKey`: `esx_identifier` or `license`

## Remove Command
`Config.RemoveCommand` enables `/removeitem` and sets permissions.

- `Enabled`: Toggle the command
- `CommandName`: Command name (default `removeitem`)
- `AllowedGroups`: ESX groups allowed to use the command
