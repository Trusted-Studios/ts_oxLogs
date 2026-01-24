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
