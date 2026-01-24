# Webhooks

Each log type uses a dedicated webhook entry in `Config.Webhooks`.

## Event Mapping
- Drop item: `drop`
- Pickup item: `pickup`
- Player to player transfer: `give`
- Stash deposit or withdraw: `stash`
- Dupe suspicion: `dupe`
- Item creation (addItem/shop/conversion): `create`
- Item removal (RemoveItem or `/removeitem`): `remove`

## Fallbacks
Some logs use a fallback webhook when a specific key is empty:
- If `create` is empty, it falls back to `give`
- If `remove` is empty, it falls back to `stash`
- If `dupe` is empty, it falls back to `stash`

## Notes
- Webhook URLs should be full Discord webhook endpoints.
- If a webhook is blank, that log is disabled or falls back (see above).
