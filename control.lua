-- Copyright (c) 2022 Branko Majic
-- Provided under MIT license. See LICENSE for details.


-- Main implementation
-- ===================

local qvs = {}


--- Vertically swaps quickbar slots.
--
-- @param player LuaPlayer Player for which to perform the swap.
--
function qvs.swap(player)
    local slot_a_index
    local slot_b_index
    local slot_a_filter
    local slot_b_filter

    for row_index = 1, 10 do
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
    qvs.swap(player)
end


-- Event handler registration
-- ==========================

script.on_event("qvs-swap", qvs.on_qvs_swap)
