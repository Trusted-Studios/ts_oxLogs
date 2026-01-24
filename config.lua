Config = {}

Config.Webhooks = {
    base   =
    "discord_webhook",
    drop   =
    "discord_webhook",
    pickup =
    "discord_webhook",
    give   =
    "discord_webhook",
    stash  =
    "discord_webhook",
    dupe   =
    "discord_webhook",
    create =
    "discord_webhook",
    remove =
    "discord_webhook",
}

Config.Discord = {
    Username      = "Inventory Logs",
    AvatarUrl     = "https://i.imgur.com/IdorGF4.png",

    ServerName    = "MyServer",
    FooterText    = "<@Trusted Studios> | ox_inventory Logs",
    FooterIcon    = "https://i.imgur.com/IdorGF4.png",
    AuthorIcon    = "https://i.imgur.com/IdorGF4.png",

    UseFieldIcons = true,
}

Config.Locale = "en"

Config.Translations = {
    en = {
        labels = {
            player = "Player",
            esx = "ESX",
            license = "License",
            steam = "Steam",
            discord = "Discord",
            position = "Position",
            ip = "IP",
            item = "Item",
            amount = "Amount",
            action = "Action",
            metadata = "Metadata",
            removed_by = "Removed by",
            admin_group = "Admin group",
            admin_identifier = "Admin identifier",
            target_inventory = "Target inventory",
            target_inventory_player = "Target inventory (player)",
            target_inventory_stash = "Target inventory (stash)",
            target_inventory_drop = "Target inventory (drop)",
            target_player = "Target player",
            target = "Target",
            reason = "Reason",
            slot = "Slot",
            stash = "Stash",
        },
        embeds = {
            dupe_title = "Dupe suspected",
            dupe_desc = "Suspicious inventory pattern detected.",
            remove_title = "Item removed (RemoveItem)",
            remove_desc = "An item was removed from an inventory via command/script.",
            drop_title = "Item dropped",
            drop_desc = "An item was dropped on the ground.",
            pickup_title = "Item picked up",
            pickup_desc = "An item was picked up from the ground.",
            give_title = "Item transferred",
            give_desc = "An item was transferred between players.",
            stash_put_title = "Item stored",
            stash_put_desc = "An item was placed into a stash.",
            stash_take_title = "Item withdrawn",
            stash_take_desc = "An item was taken from a stash.",
            create_title = "Item created (AddItem)",
            create_desc = "An item was created (e.g. AddItem/shop/conversion).",
        },
        templates = {
            esx_info = "Identifier: `{identifier}`\nJob: `{job}`\nGroup: `{group}`",
            target_player = "**{name}** (ID: `{id}`)\nIdentifier: `{identifier}`\nJob: `{job}`\nGroup: `{group}`",
            target_player_short = "**{name}** (ID: `{id}`)\nESX: `{identifier}`\nJob: `{job}`\nGroup: `{group}`",
        },
        messages = {
            ox_inventory_not_running = "^1[InventoryLogs]^0 ox_inventory is not running.",
            hooks_active = "^2[InventoryLogs]^0 ox_inventory hooks active (swapItems + createItem).",
            remove_ingame_only = "[removeitem] In-game only (source).",
            no_permission = "No permission.",
            usage_removeitem = "Usage: /removeitem <id> <item> <count>",
            target_not_online = "Target player is not online.",
            remove_failed = "RemoveItem failed (item missing or insufficient).",
            remove_success = "Removed: {count}x {item} from ID {id}",
            error_prefix = "^1Error",
            ok_prefix = "^2OK",
            usage_prefix = "^3Usage",
        }
    },
    de = {
        labels = {
            player = "Spieler",
            esx = "ESX",
            license = "License",
            steam = "Steam",
            discord = "Discord",
            position = "Position",
            ip = "IP",
            item = "Item",
            amount = "Menge",
            action = "Aktion",
            metadata = "Metadaten",
            removed_by = "Entfernt von",
            admin_group = "Admin Gruppe",
            admin_identifier = "Admin Identifier",
            target_inventory = "Ziel-Inventory",
            target_inventory_player = "Ziel-Inventory (Player)",
            target_inventory_stash = "Ziel-Inventory (Stash)",
            target_inventory_drop = "Ziel-Inventory (Drop)",
            target_player = "Ziel-Spieler",
            target = "Ziel",
            reason = "Grund",
            slot = "Slot",
            stash = "Stash",
        },
        embeds = {
            dupe_title = "Dupe-Verdacht",
            dupe_desc = "Verdächtiges Inventar-Pattern erkannt.",
            remove_title = "Item gelöscht (RemoveItem)",
            remove_desc = "Ein Item wurde per Befehl/Script aus einem Inventar entfernt.",
            drop_title = "Item abgelegt",
            drop_desc = "Ein Item wurde auf den Boden abgelegt.",
            pickup_title = "Item aufgehoben",
            pickup_desc = "Ein Item wurde vom Boden aufgehoben.",
            give_title = "Item übergeben",
            give_desc = "Ein Item wurde zwischen Spielern übertragen.",
            stash_put_title = "In Lager gelegt",
            stash_put_desc = "Ein Item wurde in ein Lager (Stash) gelegt.",
            stash_take_title = "Aus Lager genommen",
            stash_take_desc = "Ein Item wurde aus einem Lager (Stash) genommen.",
            create_title = "Item erstellt (AddItem)",
            create_desc = "Ein Item wurde erstellt (z. B. AddItem/Shop/Conversion).",
        },
        templates = {
            esx_info = "Identifier: `{identifier}`\nJob: `{job}`\nGroup: `{group}`",
            target_player = "**{name}** (ID: `{id}`)\nIdentifier: `{identifier}`\nJob: `{job}`\nGroup: `{group}`",
            target_player_short = "**{name}** (ID: `{id}`)\nESX: `{identifier}`\nJob: `{job}`\nGroup: `{group}`",
        },
        messages = {
            ox_inventory_not_running = "^1[InventoryLogs]^0 ox_inventory läuft nicht.",
            hooks_active = "^2[InventoryLogs]^0 ox_inventory Hooks aktiv (swapItems + createItem).",
            remove_ingame_only = "[removeitem] Nur Ingame (source) unterstützt.",
            no_permission = "Keine Berechtigung.",
            usage_removeitem = "Usage: /removeitem <id> <item> <count>",
            target_not_online = "Ziel-Spieler ist nicht online.",
            remove_failed = "RemoveItem fehlgeschlagen (Item evtl. nicht vorhanden/zu wenig).",
            remove_success = "Entfernt: {count}x {item} von ID {id}",
            error_prefix = "^1Fehler",
            ok_prefix = "^2OK",
            usage_prefix = "^3Usage",
        }
    }
}

Config.Colors = {
    drop   = 0x2ecc71,
    pickup = 0x3498db,
    give   = 0xf1c40f,
    stash  = 0x9b59b6,
    dupe   = 0xe74c3c,
    create = 0x95a5a6,
    remove = 0xe67e22,
}

Config.Privacy = {
    LogIP  = true,
    MaskIP = false,
}

Config.Dupe = {
    Enabled = true,

    -- optional: nur bestimmte Items prüfen (Whitelist). Leer = alle
    ItemWhitelist = {}, -- z.B. { money = true, black_money = true }

    MaxSingleMoveDefault = 200,
    MaxSingleMoveByItem = {
        -- ["money"] = 10000,
        -- ["black_money"] = 5000,
    },

    WindowSeconds = 10,
    MaxActionsInWindow = 30,

    AutoBlacklist = true,
    KickOnBlacklist = false,
    BlacklistReason = "Dupe-Verdacht (Auto)",

    KvpKey = "invlogs:blacklist",

    -- "esx_identifier" (empfohlen) oder "license"
    BlacklistKey = "esx_identifier",
}

-- Command Permissions (ESX Gruppe)
Config.RemoveCommand = {
    Enabled = false,
    CommandName = "removeitem",
    AllowedGroups = {
        superadmin = true,
        admin = true,
        mod = true,
    }
}
