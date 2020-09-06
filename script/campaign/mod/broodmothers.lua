local broodmother_manager = get_broodmother_manager()



-- intialize UI; add the button to the end-turn docker and attach the panel to clicking that button
local function ui_init()
    -- grab the docker and check that it exists!
    local docker = find_uicomponent("layout", "faction_buttons_docker", "button_group_management")
    if not is_uicomponent(docker) then
        ModLog("ui_init triggered but docker ersn't found = big issue!")
        return false
    end

    -- add the new button, and use "Layout()" on the parent, which is needed to refresh the spacing of the buttons and add the new one to the list.
    local new_uic = core:get_or_create_component("button_broodmother", "ui/templates/round_large_button", docker)
    new_uic:SetImagePath("ui/skins/default/broodmother_icon.png")
    
    docker:Layout()

    -- listen for the Broodmother button being pressed
    core:add_listener(
        "broodmother_clicked",
        "ComponentLClickUp",
        function(context)
            return context.string == "button_broodmother"
        end,
        function(context)
            broodmother_manager:get_ui():create_panel()
        end,
        true
    )
end

-- check to see if the local player is Skaven; if they are, initialize the UI
cm:add_first_tick_callback(function()
    local faction_key = cm:get_local_faction(true)
    local faction = cm:get_faction(faction_key)
    if faction:culture() == "wh2_main_skv_skaven" then
        ui_init()
    end

    broodmother_manager:new_game_startup()
end)