-- Copyright (c) 2022 Branko Majic
-- Provided under MIT license. See LICENSE for details.


-- Main implementation
-- ===================

local qvs = {}


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
        rows = {1, 2, 3, 4, 5, 6, 7, 8, 9, 10}
    else
        rows = {}
        for row_index = 1, tonumber(mode:sub(-1)) do
            table.insert(rows, player.get_active_quick_bar_page(row_index))
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

    for _, row_index in ipairs(rows) do
        for slot_index = 1, 5 do
            slot_a_index = (row_index - 1) * 10 + slot_index
            slot_b_index = (row_index - 1) * 10 + slot_index + 5

            slot_a_filter = player.get_quick_bar_slot(slot_a_index)
            slot_b_filter = player.get_quick_bar_slot(slot_b_index)

            -- Blueprints cannot be swapped, and nil values cannot be distinguished from library blueprints.
            if slot_a_filter and slot_a_filter.name ~= "blueprint" and slot_b_filter and slot_b_filter.name ~= "blueprint" then
                player.set_quick_bar_slot(slot_a_index, slot_b_filter)
                player.set_quick_bar_slot(slot_b_index, slot_a_filter)
            end
        end
    end
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


--- Retrieve swap mode for a given player.
--
-- Thing wrapper around the per-player setting.
--
-- @return string Swap mode. See setting "qvs-swap-mode" for valid values.
--
function qvs.get_swap_mode(player)
    return player.mod_settings["qvs-swap-mode"].value
end


-- Event handler registration
-- ==========================

script.on_event("qvs-swap", qvs.on_qvs_swap)
script.on_event(defines.events.on_runtime_mod_setting_changed, qvs.on_runtime_mod_setting_changed)
