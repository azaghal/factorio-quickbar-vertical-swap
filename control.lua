-- Copyright (c) 2022 Branko Majic
-- Provided under MIT license. See LICENSE for details.


-- Main implementation
-- ===================

local qvs = {}


--- Initialises global data structures.
--
function qvs.init_data()
    global.player_data = global.player_data or {}

    for _, player in pairs(game.players) do
        qvs.init_player_data(player)
    end
end


--- Initialises global data structures for a partciular player.
--
-- @param player LuaPlayer Player for which to initialise the data structures.
--
function qvs.init_player_data(player)
    global.player_data[player.index] = global.player_data[player.index] or {}
    qvs.update_quickbar_blacklist(player)
end


--- Removes all player data from global data structures.
--
-- @param player LuaPlayer Player for which to remove all data.
--
function qvs.remove_player_data(player)
    global.player_data[player.index] = nil
end


--- Retrieve swap mode for a given player.
--
-- Thin wrapper around the per-player setting.
--
-- @return string Swap mode. See setting "qvs-swap-mode" for valid values.
--
function qvs.get_swap_mode(player)
    return player.mod_settings["qvs-swap-mode"].value
end


--- Retrieves quickbar blacklist for a player.
--
-- @param player LuaPlayer Player for which to retrieve the blacklist.
--
-- @return table{uint8 = bool}|nil Quickbar blacklist table, mapping quickbar rows to their blacklist status.
--
function qvs.get_quickbar_blacklist(player)
    return global.player_data[player.index].quickbar_blacklist
end


--- Checks if player has enabled blueprint protection (for game/player library).
--
-- Thin wrapper around the per-player setting.
--
-- @return bool true, if player has enabled blueprint protection, false otherwise.
--
function qvs.is_blueprint_protection_enabled(player)
    return player.mod_settings["qvs-blueprint-protection"].value
end


--- Updates quickbar blacklist for a player.
--
-- Parses the player settings and updates the internal data structure.
--
-- If player setting is invalid, quickbar blacklist is set to nil, and an error message is shown to the player.
--
-- @param player LuaPlayer Player for which to update the blacklist.
--
function qvs.update_quickbar_blacklist(player)
    local setting = player.mod_settings["qvs-quickbar-blacklist"].value
    local parsed_setting = qvs.parse_quickbar_blacklist_setting(setting)
    local player_data = global.player_data[player.index]
    local quickbar_blacklist = {}

    if parsed_setting then
        -- Set-up empty quickbar blacklist.
        player_data.quickbar_blacklist = {}

        for row_index = 1, 10 do
            player_data.quickbar_blacklist[row_index] = parsed_setting[row_index] or false
        end
    else
        player_data.quickbar_blacklist = nil
        player.print({"error.qvs-invalid-quickbar-blacklist"})
    end
end


--- Parses quickbar blacklist setting.
--
-- @param value string Comma-separated list of quickbar rows.
--
-- @return table|nil List of black-listed quickbar rows if successful, or nil if parsing has failed.
--
function qvs.parse_quickbar_blacklist_setting(value)
    local blacklist = {}

    for row_index in string.gmatch(value, "([^,]+)") do
        row_index = tonumber(row_index)

        if row_index and string.find(row_index, "^%d+$") and row_index >= 1 and row_index <= 10 then
            blacklist[row_index] = true
        else
            return nil
        end

    end

    return blacklist
end


--- Checks if the specified quickbar row is black-listed by the player
--
-- @param player LuaPlayer Player for which to perform the check.
-- @param quickbar_row uint8 Quickbar row to check
--
-- @return bool true, if the quickbar row is black-listed, false otherwise.
function qvs.is_quickbar_row_blacklisted(player, quickbar_row)
    local quickbar_blacklist = qvs.get_quickbar_blacklist(player)

    if quickbar_blacklist == nil then
        player.print({"error.qvs-invalid-quickbar-blacklist"})
        return false
    end

    return quickbar_blacklist[quickbar_row] or false
end


--- Retrieves list of quickbar rows on which to perform vertical swapping.
--
-- @param player LuaPlayer Player invoking the swapping operation.
-- @param mode string Swap mode of operation. See setting "qvs-swap-mode" for valid values.
--
-- @return table List of quickbar rows that should be vertically swapped.
--
function qvs.get_quickbar_rows_to_swap(player, mode)
    local rows = {}

    if mode == "all" then
        for row = 1, 10 do
            if not qvs.is_quickbar_row_blacklisted(player, row) then
                table.insert(rows, row)
            end
        end
    else
        for active_row = 1, tonumber(mode:sub(-1)) do
            local row = player.get_active_quick_bar_page(active_row)
            if not qvs.is_quickbar_row_blacklisted(player, row) then
                table.insert(rows, row)
            end
        end
    end

    return rows
end


--- Vertically swaps quickbar slots.
--
-- @param player LuaPlayer Player for which to perform the swap.
--
function qvs.swap(player, mode)
    local rows = qvs.get_quickbar_rows_to_swap(player, mode)

    local slot_a_index
    local slot_b_index
    local slot_a_filter
    local slot_b_filter
    local slot_a_can_swap
    local slot_b_can_swap

    for _, row_index in ipairs(rows) do
        for slot_index = 1, 5 do
            slot_a_index = (row_index - 1) * 10 + slot_index
            slot_b_index = (row_index - 1) * 10 + slot_index + 5

            slot_a_filter = player.get_quick_bar_slot(slot_a_index)
            slot_b_filter = player.get_quick_bar_slot(slot_b_index)

            -- Figure out if we are allowed to swap the two slots. Inventory blueprints cannot be swapped. However,
            -- game/player blueprints cannot be detected (they return as nil values), and we let the player decide how
            -- to treat empty (from mod perspective) slots.
            slot_a_can_swap =
                (slot_a_filter ~= nil and slot_a_filter.name ~= "blueprint") and true or
                (slot_a_filter == nil and not qvs.is_blueprint_protection_enabled(player)) and true or
                false
            slot_b_can_swap =
                (slot_b_filter ~= nil and slot_b_filter.name ~= "blueprint") and true or
                (slot_b_filter == nil and not qvs.is_blueprint_protection_enabled(player)) and true or
                false

            -- Checking if at least one of the slots is non-nil is means to avoid swapping game/player blueprints in two
            -- slots (try as hard as possible to preserve them).
            if (slot_a_filter or slot_b_filter) and slot_a_can_swap and slot_b_can_swap then
                player.set_quick_bar_slot(slot_a_index, slot_b_filter)
                player.set_quick_bar_slot(slot_b_index, slot_a_filter)
            end
        end
    end
end


--- Initialisation handler. Invoked when mod is first added to the save game.
--
function qvs.on_init()
    qvs.init_data()
end


--- Handler for custom input event. Triggers vertical swapping of quickbar slots for invoking player.
--
-- @param event EventData Event data passed-on by the game engine.
--
function qvs.on_qvs_swap(event)
    local player = game.players[event.player_index]
    local mode = qvs.get_swap_mode(player)

    qvs.swap(player, mode)
end


--- Handler invoked when player changes mod settings.
--
-- @param event EventData Event data passed-on by the game engine.
--
function qvs.on_runtime_mod_setting_changed(event)
    if event.setting_type == "runtime-per-user" and event.setting == "qvs-quickbar-blacklist" then
        local player = game.players[event.player_index]
        local player_data = global.player_data[player.index]

        qvs.update_quickbar_blacklist(player, player_data)
    end
end


--- Handler invoked when player is created.
--
-- @param event EventData Event data passed-on by the game engine.
--
function qvs.on_player_created(event)
    local player = game.players[event.player_index]
    qvs.init_player_data(player)
end


--- Handler invoked when player is removed from the game.
--
-- @param event EventData Event data passed-on by the game engine.
--
function qvs.on_player_removed(event)
    local player = game.players[event.player_index]
    qvs.remove_player_data(player)
end


-- Event handler registration
-- ==========================

script.on_init(qvs.on_init)

script.on_event(defines.events.on_player_created, qvs.on_player_created)
script.on_event(defines.events.on_player_removed, qvs.on_player_removed)
script.on_event(defines.events.on_runtime_mod_setting_changed, qvs.on_runtime_mod_setting_changed)

script.on_event("qvs-swap", qvs.on_qvs_swap)
