--============================================================
-- ESX
--============================================================
local ESX = nil

local function initESX()
    if ESX then return end
    local ok, obj = pcall(function()
        return exports["es_extended"]:getSharedObject()
    end)
    if ok then ESX = obj end
end

local function esxInfo(src)
    initESX()

    local info = {
        identifier = "n/a",
        job = "n/a",
        group = "n/a"
    }

    if not ESX or not ESX.GetPlayerFromId then
        return info
    end

    local xPlayer = ESX.GetPlayerFromId(src)
    if not xPlayer then
        return info
    end

    info.identifier = xPlayer.identifier or "n/a"

    if xPlayer.job and xPlayer.job.name then
        info.job = string.format("%s / %s", xPlayer.job.name, tostring(xPlayer.job.grade or "?"))
    end

    if xPlayer.getGroup then
        info.group = xPlayer.getGroup() or "n/a"
    end

    return info
end

local function isAllowedGroup(src)
    if not Config.RemoveCommand.Enabled then return false end
    local g = esxInfo(src).group
    return Config.RemoveCommand.AllowedGroups[g] == true
end

--============================================================
-- Translations
--============================================================
local function resolveTranslation(lang, key)
    local root = Config.Translations and Config.Translations[lang]
    if type(root) ~= "table" then return nil end

    local node = root
    for part in key:gmatch("[^%.]+") do
        if type(node) ~= "table" then return nil end
        node = node[part]
    end

    return node
end

local function t(key, vars)
    local locale = Config.Locale or "en"
    local str = resolveTranslation(locale, key) or resolveTranslation("en", key)
    if type(str) ~= "string" then return key end

    if vars then
        for k, v in pairs(vars) do
            str = str:gsub("{" .. k .. "}", tostring(v))
        end
    end

    return str
end

--============================================================
-- Identifier / Player Utils
--============================================================
local function getIdentifier(src, prefix)
    local ids = GetPlayerIdentifiers(src)
    if not ids then return nil end
    for _, v in ipairs(ids) do
        if v:sub(1, #prefix) == prefix then
            return v
        end
    end
    return nil
end

local function getDiscordId(src)
    local d = getIdentifier(src, "discord:")
    return d and d:gsub("discord:", "") or nil
end

local function getLicense(src) return getIdentifier(src, "license:") end
local function getSteam(src)   return getIdentifier(src, "steam:") end
local function getFivem(src)   return getIdentifier(src, "fivem:") end

local function bestIdentifier(src)
    return getLicense(src) or getSteam(src) or getFivem(src) or "unknown"
end

local function pname(src)
    return GetPlayerName(src) or ("unknown(" .. tostring(src) .. ")")
end

local function pcoords(src)
    local ped = GetPlayerPed(src)
    if ped == 0 then return "0.00, 0.00, 0.00" end
    local c = GetEntityCoords(ped)
    return string.format("%.2f, %.2f, %.2f", c.x, c.y, c.z)
end

local function getIP(src)
    local endpoint = GetPlayerEndpoint(src)
    if not endpoint or endpoint == "" then return nil end

    if not Config.Privacy.MaskIP then
        return endpoint
    end

    local a, b, c = endpoint:match("^(%d+)%.(%d+)%.(%d+)%..+$")
    if a and b and c then
        return string.format("%s.%s.%s.xxx", a, b, c)
    end
    return "masked"
end

local function safeStr(v)
    if v == nil then return "n/a" end
    return tostring(v)
end

--============================================================
-- Item / Payload Utils
--============================================================
local function slotName(slot)
    return slot and slot.name or "unknown"
end

local function slotMeta(slot)
    return json.encode(slot and slot.metadata or {})
end

local function movedCount(payload)
    -- swapItems: payload.count ist die bewegte Menge (wichtig bei stack)
    local c = tonumber(payload and payload.count) or 0
    if c > 0 then return c end
    return tonumber(payload and payload.fromSlot and payload.fromSlot.count) or 0
end

local function resolvePlayerId(inv)
    if type(inv) == "number" then return inv end
    if type(inv) == "string" then
        local n = tonumber(inv)
        if n then return n end
        local idStr = inv:match("^player:(%d+)$") or inv:match(":(%d+)$")
        if idStr then return tonumber(idStr) end
    end
    return nil
end

local function normalizeInventory(inv)
    if inv == nil then return "unknown", "n/a" end
    if type(inv) == "number" then return "player", tostring(inv) end

    if type(inv) == "string" then
        local pid = resolvePlayerId(inv)
        if pid then return "player", tostring(pid) end

        local t, id = inv:match("^(%w+):(.+)$")
        if t and id then return string.lower(t), tostring(id) end

        return "stash", inv
    end

    return "unknown", tostring(inv)
end

--============================================================
-- Discord Sender (Rate-Limit)
--============================================================
local function sendDiscordRaw(url, payloadTable)
    if not url or url == "" then return end
    local body = json.encode(payloadTable)

    PerformHttpRequest(url, function(code, text)
        if code == 200 or code == 204 then return end

        if code == 429 then
            local wait = 1000
            if text and text ~= "" then
                local ok, data = pcall(json.decode, text)
                if ok and data and data.retry_after then
                    wait = tonumber(data.retry_after) or wait
                end
            end
            SetTimeout(wait, function()
                PerformHttpRequest(url, function() end, "POST", body, { ["Content-Type"] = "application/json" })
            end)
            return
        end

        print(("[InventoryLogs] Webhook error %s: %s"):format(tostring(code), tostring(text)))
    end, "POST", body, { ["Content-Type"] = "application/json" })
end

local function sendWebhook(key, embeds)
    local url = Config.Webhooks[key]
    if not url or url == "" then return end

    sendDiscordRaw(url, {
        username = Config.Discord.Username,
        avatar_url = (Config.Discord.AvatarUrl ~= "" and Config.Discord.AvatarUrl) or nil,
        embeds = embeds
    })
end

--============================================================
-- Embed Builder
--============================================================
local function fi(label, value, inline)
    return { name = label, value = value, inline = inline or false }
end

local function withIcon(label, icon)
    if not Config.Discord.UseFieldIcons then return label end
    return icon .. " " .. label
end

local function baseEmbed(title, color)
    return {
        title = title,
        color = color,
        timestamp = os.date("!%Y-%m-%dT%H:%M:%SZ"),
        author = {
            name = Config.Discord.ServerName,
            icon_url = (Config.Discord.AuthorIcon ~= "" and Config.Discord.AuthorIcon) or nil,
        },
        footer = {
            text = Config.Discord.FooterText,
            icon_url = (Config.Discord.FooterIcon ~= "" and Config.Discord.FooterIcon) or nil,
        }
    }
end

local function playerFields(src)
    local esx = esxInfo(src)
    local did = getDiscordId(src)
    local mention = did and ("<@" .. did .. ">") or "n/a"

    local fields = {
        fi(withIcon(t("labels.player"), "👤"), ("**%s** (ID: `%s`)"):format(pname(src), tostring(src)), true),
        fi(withIcon(t("labels.esx"), "🧾"), t("templates.esx_info", { identifier = safeStr(esx.identifier), job = safeStr(esx.job), group = safeStr(esx.group) }), false),
        fi(withIcon(t("labels.license"), "🔐"), "`" .. safeStr(getLicense(src)) .. "`", true),
        fi(withIcon(t("labels.steam"), "🎮"), "`" .. safeStr(getSteam(src)) .. "`", true),
        fi(withIcon(t("labels.discord"), "💬"), mention, true),
        fi(withIcon(t("labels.position"), "📍"), "`" .. pcoords(src) .. "`", true),
    }

    if Config.Privacy.LogIP then
        fields[#fields + 1] = fi(withIcon(t("labels.ip"), "🌐"), "`" .. safeStr(getIP(src)) .. "`", true)
    end

    return fields
end

local function itemFieldsFromSwap(payload)
    local slot = payload and payload.fromSlot or nil
    local amount = movedCount(payload)

    return {
        fi(withIcon(t("labels.item"), "📦"), "`" .. safeStr(slotName(slot)) .. "`", true),
        fi(withIcon(t("labels.amount"), "🔢"), "`" .. tostring(amount) .. "`", true),
        fi(withIcon(t("labels.action"), "⚙️"), "`" .. safeStr(payload and payload.action) .. "`", true),
        fi(withIcon(t("labels.metadata"), "🧾"), "```json\n" .. safeStr(slotMeta(slot)) .. "\n```", false),
    }
end

local function adminFields(removerSrc)
    local esx = esxInfo(removerSrc)
    return {
        fi(withIcon(t("labels.removed_by"), "🛠️"), ("**%s** (ID: `%s`)"):format(pname(removerSrc), tostring(removerSrc)), true),
        fi(withIcon(t("labels.admin_group"), "🧷"), "`" .. safeStr(esx.group) .. "`", true),
        fi(withIcon(t("labels.admin_identifier"), "🪪"), "`" .. safeStr(esx.identifier) .. "`", false),
    }
end

local function inventoryField(invType, invId)
    local label = t("labels.target_inventory")
    local icon = "🗃️"

    if invType == "player" then
        label, icon = t("labels.target_inventory_player"), "👤"
    elseif invType == "stash" then
        label, icon = t("labels.target_inventory_stash"), "🗄️"
    elseif invType == "drop" then
        label, icon = t("labels.target_inventory_drop"), "🧺"
    end

    return fi(withIcon(label, icon), "`" .. safeStr(invType) .. ":" .. safeStr(invId) .. "`", false)
end

--============================================================
-- Dupe Heuristik + Blacklist (KVP) – kurz (wie zuvor)
--============================================================
local actionWindow = {}

local function getBlacklistKey(src)
    local esx = esxInfo(src)
    if Config.Dupe.BlacklistKey == "esx_identifier" and esx.identifier and esx.identifier ~= "n/a" then
        return esx.identifier
    end
    return getLicense(src) or bestIdentifier(src)
end

local function readBlacklist()
    local raw = GetResourceKvpString(Config.Dupe.KvpKey)
    if not raw or raw == "" then return {} end
    local ok, data = pcall(json.decode, raw)
    return (ok and type(data) == "table") and data or {}
end

local function isBlacklisted(key) return readBlacklist()[key] ~= nil end

local function addBlacklist(key, info)
    local data = readBlacklist()
    data[key] = info
    SetResourceKvp(Config.Dupe.KvpKey, json.encode(data))
end

local function itemWhitelisted(item)
    if not Config.Dupe.ItemWhitelist or next(Config.Dupe.ItemWhitelist) == nil then return true end
    return Config.Dupe.ItemWhitelist[item] == true
end

local function maxSingleMoveFor(item)
    local by = Config.Dupe.MaxSingleMoveByItem or {}
    if by[item] ~= nil then return tonumber(by[item]) or Config.Dupe.MaxSingleMoveDefault end
    return Config.Dupe.MaxSingleMoveDefault
end

local function dupeHeuristic(src, payload)
    if not Config.Dupe.Enabled then return false, nil end
    local it = slotName(payload and payload.fromSlot)
    if not itemWhitelisted(it) then return false, nil end

    local moved = movedCount(payload)
    local maxMove = maxSingleMoveFor(it)
    if moved >= maxMove then
        return true, ("SingleMove >= %d (moved=%d, item=%s)"):format(maxMove, moved, it)
    end

    local now = os.time()
    actionWindow[src] = actionWindow[src] or {}
    table.insert(actionWindow[src], now)

    local keep = {}
    for _, t in ipairs(actionWindow[src]) do
        if (now - t) <= Config.Dupe.WindowSeconds then keep[#keep+1] = t end
    end
    actionWindow[src] = keep

    if #keep >= Config.Dupe.MaxActionsInWindow then
        return true, ("ActionsInWindow >= %d (count=%d/%ds)"):format(
            Config.Dupe.MaxActionsInWindow, #keep, Config.Dupe.WindowSeconds
        )
    end

    return false, nil
end

local function logDupe(src, payload, reason)
    local e = baseEmbed(t("embeds.dupe_title"), Config.Colors.dupe)
    e.description = t("embeds.dupe_desc")
    e.fields = {}

    for _, f in ipairs(playerFields(src)) do e.fields[#e.fields+1] = f end
    e.fields[#e.fields+1] = fi(withIcon(t("labels.reason"), "⚠️"), "`" .. safeStr(reason) .. "`", false)
    for _, f in ipairs(itemFieldsFromSwap(payload)) do e.fields[#e.fields+1] = f end

    local key = (Config.Webhooks.dupe ~= "" and "dupe") or "stash"
    sendWebhook(key, { e })
end

local function handleBlacklist(src, reason, payload)
    if not Config.Dupe.AutoBlacklist then return end
    local key = getBlacklistKey(src)
    if not key or key == "unknown" then return end

    if not isBlacklisted(key) then
        addBlacklist(key, {
            at = os.date("!%Y-%m-%dT%H:%M:%SZ"),
            name = pname(src),
            reason = reason,
            bestIdentifier = bestIdentifier(src),
            esx = esxInfo(src),
            payload = payload and {
                action = payload.action,
                fromType = payload.fromType,
                toType = payload.toType,
                fromInventory = payload.fromInventory,
                toInventory = payload.toInventory,
                count = payload.count,
                item = payload.fromSlot and payload.fromSlot.name or nil,
            } or nil
        })
        print(("[InventoryLogs] Blacklisted %s key=%s reason=%s"):format(pname(src), tostring(key), tostring(reason)))
    end

    if Config.Dupe.KickOnBlacklist then
        DropPlayer(src, Config.Dupe.BlacklistReason)
    end
end

--============================================================
-- REMOVE EMBED + SENDER
--============================================================
local function buildRemoveEmbed(removerSrc, targetInv, item, count, metadata, slot, reason)
    local invType, invId = normalizeInventory(targetInv)

    local e = baseEmbed(t("embeds.remove_title"), Config.Colors.remove)
    e.description = t("embeds.remove_desc")
    e.fields = {}

    for _, f in ipairs(adminFields(removerSrc)) do e.fields[#e.fields+1] = f end
    e.fields[#e.fields+1] = inventoryField(invType, invId)

    if invType == "player" then
        local targetId = tonumber(invId)
        if targetId then
            local esxT = esxInfo(targetId)
            e.fields[#e.fields+1] = fi(withIcon(t("labels.target_player"), "🎯"),
                t("templates.target_player", { name = pname(targetId), id = tostring(targetId), identifier = safeStr(esxT.identifier), job = safeStr(esxT.job), group = safeStr(esxT.group) }),
                false
            )
        end
    end

    e.fields[#e.fields+1] = fi(withIcon(t("labels.item"), "🗑️"), "`" .. safeStr(item) .. "`", true)
    e.fields[#e.fields+1] = fi(withIcon(t("labels.amount"), "🔢"), "`" .. tostring(tonumber(count) or 0) .. "`", true)
    e.fields[#e.fields+1] = fi(withIcon(t("labels.slot"), "🎯"), "`" .. safeStr(slot) .. "`", true)
    e.fields[#e.fields+1] = fi(withIcon(t("labels.metadata"), "🧾"), "```json\n" .. json.encode(metadata or {}) .. "\n```", false)

    if reason and reason ~= "" then
        e.fields[#e.fields+1] = fi(withIcon(t("labels.reason"), "📝"), "`" .. safeStr(reason) .. "`", false)
    end

    return e
end

local function sendRemoveEmbed(embed)
    local key = (Config.Webhooks.remove ~= "" and "remove") or "stash"
    sendWebhook(key, { embed })
end

--============================================================
-- OX HOOKS
--============================================================
local function register()
    if GetResourceState("ox_inventory") ~= "started" then
        print(t("messages.ox_inventory_not_running"))
        return
    end

    -- swapItems: Move/Stack/Swap/Give
    exports.ox_inventory:registerHook("swapItems", function(p)
        if not p or not p.source then return end
        local src = p.source

        -- Blacklist check
        if Config.Dupe.Enabled and Config.Dupe.AutoBlacklist then
            local bkey = getBlacklistKey(src)
            if bkey and bkey ~= "unknown" and isBlacklisted(bkey) then
                if Config.Dupe.KickOnBlacklist then
                    DropPlayer(src, Config.Dupe.BlacklistReason)
                end
                return
            end
        end

        -- Dupe
        local suspect, reason = dupeHeuristic(src, p)
        if suspect then
            logDupe(src, p, reason)
            handleBlacklist(src, reason, p)
        end

        local from, to = p.fromType, p.toType
        local action = p.action

        -- DROP
        if from == "player" and to == "drop" then
            local e = baseEmbed(t("embeds.drop_title"), Config.Colors.drop)
            e.description = t("embeds.drop_desc")
            e.fields = {}
            for _, f in ipairs(playerFields(src)) do e.fields[#e.fields+1] = f end
            for _, f in ipairs(itemFieldsFromSwap(p)) do e.fields[#e.fields+1] = f end
            sendWebhook("drop", { e })
            return
        end

        -- PICKUP
        if from == "drop" and to == "player" then
            local e = baseEmbed(t("embeds.pickup_title"), Config.Colors.pickup)
            e.description = t("embeds.pickup_desc")
            e.fields = {}
            for _, f in ipairs(playerFields(src)) do e.fields[#e.fields+1] = f end
            for _, f in ipairs(itemFieldsFromSwap(p)) do e.fields[#e.fields+1] = f end
            sendWebhook("pickup", { e })
            return
        end

        -- GIVE / Player→Player Transfer
        if from == "player" and to == "player" then
            local targetId = resolvePlayerId(p.toInventory)
            if targetId and targetId ~= src then
                if action == "give" or action == "move" or action == "swap" or action == "stack" then
                    local e = baseEmbed(t("embeds.give_title"), Config.Colors.give)
                    e.description = t("embeds.give_desc")
                    e.fields = {}

                    for _, f in ipairs(playerFields(src)) do e.fields[#e.fields+1] = f end

                    local esxT = esxInfo(targetId)
                    e.fields[#e.fields+1] = fi(withIcon(t("labels.target"), "🎯"),
                        t("templates.target_player_short", { name = pname(targetId), id = tostring(targetId), identifier = safeStr(esxT.identifier), job = safeStr(esxT.job), group = safeStr(esxT.group) }),
                        false
                    )

                    for _, f in ipairs(itemFieldsFromSwap(p)) do e.fields[#e.fields+1] = f end

                    sendWebhook("give", { e })
                    return
                end
            end
        end

        -- STASH PUT
        if from == "player" and to == "stash" then
            local e = baseEmbed(t("embeds.stash_put_title"), Config.Colors.stash)
            e.description = t("embeds.stash_put_desc")
            e.fields = {}
            for _, f in ipairs(playerFields(src)) do e.fields[#e.fields+1] = f end
            e.fields[#e.fields+1] = fi(withIcon(t("labels.stash"), "🗄️"), "`" .. safeStr(p.toInventory) .. "`", true)
            for _, f in ipairs(itemFieldsFromSwap(p)) do e.fields[#e.fields+1] = f end
            sendWebhook("stash", { e })
            return
        end

        -- STASH TAKE
        if from == "stash" and to == "player" then
            local e = baseEmbed(t("embeds.stash_take_title"), Config.Colors.stash)
            e.description = t("embeds.stash_take_desc")
            e.fields = {}
            for _, f in ipairs(playerFields(src)) do e.fields[#e.fields+1] = f end
            e.fields[#e.fields+1] = fi(withIcon(t("labels.stash"), "🗄️"), "`" .. safeStr(p.fromInventory) .. "`", true)
            for _, f in ipairs(itemFieldsFromSwap(p)) do e.fields[#e.fields+1] = f end
            sendWebhook("stash", { e })
            return
        end
    end)

    -- createItem: AddItem/Shop/Conversion
    exports.ox_inventory:registerHook("createItem", function(p)
        if not p then return end

        local inv = p.inventoryId
        local isPlayerInv = type(inv) == "number" and GetPlayerName(inv) ~= nil
        if not isPlayerInv then return end

        local src = inv
        local item = (p.item and p.item.name) or (p.item and p.item.label) or "unknown"
        local count = tonumber(p.count) or 0
        local metadata = json.encode(p.metadata or {})

        local e = baseEmbed(t("embeds.create_title"), Config.Colors.create)
        e.description = t("embeds.create_desc")
        e.fields = {}

        for _, f in ipairs(playerFields(src)) do e.fields[#e.fields+1] = f end
        e.fields[#e.fields+1] = fi(withIcon(t("labels.item"), "📦"), "`" .. safeStr(item) .. "`", true)
        e.fields[#e.fields+1] = fi(withIcon(t("labels.amount"), "🔢"), "`" .. tostring(count) .. "`", true)
        e.fields[#e.fields+1] = fi(withIcon(t("labels.metadata"), "🧾"), "```json\n" .. metadata .. "\n```", false)

        local key = (Config.Webhooks.create ~= "" and "create") or "give"
        sendWebhook(key, { e })
    end)

    print(t("messages.hooks_active"))
end

--============================================================
-- REMOVE EVENTS
--============================================================

-- Standard ox_inventory removeItem Event (entfernt aus Inventory des Callers)
AddEventHandler("ox_inventory:removeItem", function(item, count, metadata, slot)
    local removerSrc = source
    if not removerSrc or removerSrc == 0 then return end

    local targetInv = ("player:%s"):format(tostring(removerSrc))
    local embed = buildRemoveEmbed(removerSrc, targetInv, item, count, metadata, slot, "ox_inventory:removeItem")
    sendRemoveEmbed(embed)
end)

--============================================================
-- COMMAND: /removeitem <id> <item> <count>
--============================================================
if Config.RemoveCommand.Enabled then
    RegisterCommand(Config.RemoveCommand.CommandName, function(src, args)
        if src == 0 then
            print(t("messages.remove_ingame_only"))
            return
        end

        if not isAllowedGroup(src) then
            TriggerClientEvent("chat:addMessage", src, { args = { t("messages.error_prefix"), t("messages.no_permission") } })
            return
        end

        local targetId = tonumber(args[1])
        local item = args[2]
        local count = tonumber(args[3]) or 1

        if not targetId or not item or item == "" then
            TriggerClientEvent("chat:addMessage", src, { args = { t("messages.usage_prefix"), t("messages.usage_removeitem") } })
            return
        end

        if GetPlayerName(targetId) == nil then
            TriggerClientEvent("chat:addMessage", src, { args = { t("messages.error_prefix"), t("messages.target_not_online") } })
            return
        end

        -- Log (Ziel = player:<targetId>)
        local targetInv = ("player:%s"):format(tostring(targetId))
        local embed = buildRemoveEmbed(
            src,
            targetInv,
            item,
            count,
            {},     -- metadata unbekannt bei Command
            nil,    -- slot unbekannt bei Command
            "/removeitem"
        )
        sendRemoveEmbed(embed)

        -- Entfernen
        local removed = exports.ox_inventory:RemoveItem(targetId, item, count)
        if not removed then
            TriggerClientEvent("chat:addMessage", src, { args = { t("messages.error_prefix"), t("messages.remove_failed") } })
        else
            TriggerClientEvent("chat:addMessage", src, { args = { t("messages.ok_prefix"), t("messages.remove_success", { count = count, item = item, id = targetId }) } })
        end
    end, false)
end

--============================================================
-- Start/Stop Handling
--============================================================
AddEventHandler("onResourceStart", function(res)
    if res == GetCurrentResourceName() then
        initESX()
        register()
    elseif res == "ox_inventory" then
        Wait(500)
        register()
    elseif res == "es_extended" then
        initESX()
    end
end)

AddEventHandler("onResourceStop", function(res)
    if res == GetCurrentResourceName() and GetResourceState("ox_inventory") == "started" then
        exports.ox_inventory:removeHooks()
    end
end)
