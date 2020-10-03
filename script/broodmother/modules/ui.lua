local bmm = broodmama_manager

local ui_obj = {
    panel_name = "broodmothers_panel",

    listener_names = {},

    -- 1-4 index of either broodmother key or "open" or "locked"
    slots = {

    },

    selected_slot = 0,

    selected_action = "",
}

function ui_obj:delete_component(uic)
    if not is_uicomponent(self.dummy) then
        self.dummy = core:get_or_create_component("script_dummy", "ui/mct/script_dummy")
    end

    local dummy = self.dummy

    if is_uicomponent(uic) then
        dummy:Adopt(uic:Address())
    elseif is_table(uic) then
        for i = 1, #uic do
            local test = uic[i]
            if is_uicomponent(test) then
                dummy:Adopt(test:Address())
            else
                -- ERROR WOOPS
            end
        end
    end

    dummy:DestroyChildren()
end

function ui_obj:set_state_text_with_resize(uic, text)
    if not is_uicomponent(uic) then
        -- errmsg
        return false
    end

    if not is_string(text) then
        -- errmsg
        return false
    end
    
    -- TODO figure out why l > 1 for some components

    local w,h,l = uic:TextDimensionsForText(text)
    uic:ResizeTextResizingComponentToInitialSize(w, h)
    uic:SetStateText(text)
end

function ui_obj:clear_listeners()
    for i = 1, #self.listener_names do
        core:remove_listener(self.listener_names[i])
    end

    self.listener_names = {}
end

function ui_obj:add_listener(listener_name)
    if not is_string(listener_name) then
        -- errmsg
        return false
    end

    self.listener_names[#self.listener_names+1] = listener_name
end

function ui_obj:open_frame()
    local panel = find_uicomponent(self.panel_name)

    if not is_uicomponent(panel) then
        -- create one
        self:create_panel()
    else
        panel:SetVisible(true)
    end
end

function ui_obj:close_frame()
    local panel = find_uicomponent(self.panel_name)

    self:delete_component(panel)

    self:clear_listeners()
end

-- ths was in the actions column, moving out temporarily (or maybe permanently)
local function blank_stuff()
    -- create the bottom component
    local bottom_text_bg = core:get_or_create_component("flavour_text_holder", "ui/vandy_lib/custom_image_tiled", dummy)
    bottom_text_bg:SetVisible(true)
    bottom_text_bg:SetState("custom_state_2")
    bottom_text_bg:SetImagePath("ui/skins/default/panel_stack.png", 1)
    bottom_text_bg:SetCanResizeWidth(true) bottom_text_bg:SetCanResizeHeight(true)
    bottom_text_bg:Resize(dummy:Width() * 0.95, dummy:Height() * 0.15)

    bottom_text_bg:SetDockingPoint(8)
    bottom_text_bg:SetDockOffset(0, -15)

    local bottom_text = core:get_or_create_component("flavour_text", "ui/vandy_lib/text/la_gioconda", bottom_text_bg)
    bottom_text:SetVisible(true)

    bottom_text:SetDockingPoint(5)
    bottom_text:SetDockOffset(0, 0)
    bottom_text:Resize(bottom_text_bg:Width() * 0.95, bottom_text_bg:Height() * 0.95)

    do
        local w,h = bottom_text:TextDimensionsForText("My Flavour Text")
        bottom_text:ResizeTextResizingComponentToInitialSize(w, h)
        bottom_text:SetStateText("[[col:fe_white]]My Flavour Text[[/col]]")
    end
end

-- called whenever one of the actions is pressed; changes the costs, durations, effects, flavour text, etc., in the left column
function ui_obj:populate_context_menu_on_press(action_key)
    if not is_string(action_key) then
        -- errmsg
        return false
    end

    local action = bmm:get_action_with_key(action_key)
    if not action then
        -- errmsg
        return false
    end

    local panel = find_uicomponent(self.panel_name)
    local context_column = find_uicomponent(panel, "context_column")
    local rites_holder = find_uicomponent(context_column, "dummy", "rites_holder")

    local rites_title = find_uicomponent(rites_holder, "rites_title")
    local rites_flavour = find_uicomponent(rites_holder, "rites_flavour")

    -- edit the "Rites Title" UIC to the selected action, and make sure the new text is centered
    do
        local txt = effect.get_localised_string(action.text_string)

        local ow, oh = rites_title:Width(), rites_title:Height()

        local w,h = rites_title:TextDimensionsForText(txt)
        rites_title:ResizeTextResizingComponentToInitialSize(w, h)

        rites_title:SetStateText(txt)

        rites_title:Resize(ow, oh)
        rites_title:ResizeTextResizingComponentToInitialSize(ow, oh)
    end

    -- ditto with rites flavour here
    do

    end

    -- apply gold/food costs and duration/cooldown timers
    local deets_holder = find_uicomponent(rites_holder, "deets_holder")
    local gold_holder = find_uicomponent(deets_holder, "gold_holder")
    local food_holder = find_uicomponent(deets_holder, "food_holder")
    local cooldown_holder = find_uicomponent(deets_holder, "cooldown_holder")
    local duration_holder = find_uicomponent(deets_holder, "duration_holder")

    
    -- run through the effects list, and apply everything there
    local effects_holder = find_uicomponent(rites_holder, "effects_holder")
    
    -- kill any extant effects
    effects_holder:DestroyChildren()

    local ypos = 10 -- ydock offset for effects
    local xpos = 5 -- ditto, x

    local effect_bundle = action.effect_bundle
    if not effect_bundle then
        -- issue
    else
        local eb_key = effect_bundle.key
        local effects = effect_bundle.effects

        local duration = action.duration

        if not eb_key then
            -- skip it, throw error
            return
        end

        if not is_table(effects) then
            -- ditto
            return
        end

        local common_obj = effect

        for i = 1, #effects do
            local effect = effects[i]
            local effect_key = effect.key
            local effect_image_path = effect.image_path
            local effect_value = effect.value
            local effect_scope_key = effect.effect_scope
            local effect_txt = common_obj.get_localised_string("effects_description_"..effect_key) .. common_obj.get_localised_string("campaign_effect_scopes_localised_text_"..effect_scope_key)

            local good = effect.good

            if good then
                effect_txt = "[[col:dark_g]]" .. effect_txt .. "[[/col]]"
            else
                effect_txt = "[[col:dark_r]]" .. effect_txt .. "[[/col]]"
            end

            do -- replace "n" with the value, remove "%", and remove "+"
                local val_txt = tostring(effect_value)
                local plus_val_txt = val_txt
                if effect_value > 0 then
                    plus_val_txt = "+"..val_txt
                end

                if string.find(effect_txt, "%+n") then
                    effect_txt = string.gsub(effect_txt, "%%%+n", plus_val_txt)
                else
                    if string.find(effect_txt, "%n") then
                        effect_txt = string.gsub(effect_txt, "%%n", val_txt)
                    end
                end
            end

            local effect_uic = UIComponent(effects_holder:CreateComponent(effect_key, "ui/vandy_lib/script_dummy"))
            effect_uic:Resize(effects_holder:Width() * 0.98, effect_uic:Height())
            effect_uic:SetDockingPoint(1)
            effect_uic:SetDockOffset(xpos, ypos)

            do -- make the icon UIC
                local uic = UIComponent(effect_uic:CreateComponent("icon", "ui/templates/custom_image"))
                uic:SetDockingPoint(4)
                uic:SetDockOffset(8, 0)

                uic:SetCanResizeWidth(true) uic:SetCanResizeHeight(true)
                uic:Resize(24, 24)
                uic:SetCanResizeWidth(false) uic:SetCanResizeHeight(false)

                uic:SetVisible(true)
                uic:SetState("custom_state_1")
                uic:SetImagePath(effect_image_path)
            end

            local hee

            do -- make the text UIC
                local uic = UIComponent(effect_uic:CreateComponent("text", "ui/vandy_lib/text/la_gioconda/left"))
                uic:SetDockingPoint(4)
                uic:SetDockOffset(32+5, 0)

                local ow,oh = effect_uic:Width() - 30, uic:Height()*2.1

                local w,h = uic:TextDimensionsForText(effect_txt)
                uic:ResizeTextResizingComponentToInitialSize(w, h)

                uic:SetStateText(effect_txt)

                uic:Resize(ow,oh)
                uic:ResizeTextResizingComponentToInitialSize(ow, oh)

                hee = oh*1.01
            end

            effect_uic:Resize(effects_holder:Width() * 0.98, hee)

            local _,h = effect_uic:Bounds()

            ypos = ypos + h + 10
        end


        --[[ this way does not work :)
        -- create a custom effect 
        local custom_effect_bundle = cm:create_new_custom_effect_bundle(eb_key)

        local effects_list = custom_effect_bundle:effects()
        for i = 0, effects_list:num_items() -1 do
            local effect = effects_list:item_at(i)
            local effect_key = effect:key()
            local effect_value = effect:value()

            local effect_txt = effect.get_localised_string("effects_description_"..effect_key)
            local x, z = effect_txt:find("%+n")
            if x then
                effect_txt = string.gsub(effect_txt, "%+n", tostring(effect_value))
            end

            local effect_uic = UIComponent(effects_holder:CreateComponent(effect_key, "ui/vandy_lib/script_dummy"))
            effect_uic:Resize(effects_holder:Width() * 0.9, effect_uic:Height())
            effect_uic:SetDockingPoint(1)
            effect_uic:SetDockingPoint(xpos, ypos)

            ypos = ypos + effect_uic:Height() + 10

            local effect_icon_uic = UIComponent(effect_uic:CreateComponent("icon", "ui/templates/custom_image"))
            --effect_i
            -- shit just realized I have to hard-code every icon
        end]]
    end
end

function ui_obj:create_actions_column()
    local panel = find_uicomponent(self.panel_name)
    local actions_column = find_uicomponent(panel, "actions_column")

    local img_path = effect.get_skinned_image_path("fe_plaque.png")

    -- left column, background is a current dummy
    local dummy = core:get_or_create_component("dummy", "ui/vandy_lib/custom_image_tiled", actions_column)
    dummy:SetVisible(true)
    dummy:SetState("custom_state_2")
    dummy:SetImagePath("ui/skins/warhammer2/panel_back_top.png", 1)
    dummy:SetCanResizeWidth(true) dummy:SetCanResizeHeight(true)
    dummy:Resize(actions_column:Width(), actions_column:Height())

    dummy:SetDockingPoint(5)
    dummy:SetDockOffset(0, 0)

    local border = core:get_or_create_component("border", "ui/vandy_lib/custom_image_tiled", dummy)
    border:SetVisible(true)
    border:SetState('custom_state_2')
    border:SetImagePath("ui/skins/warhammer2/panel_back_frame.png", 1)
    border:SetCanResizeWidth(true) dummy:SetCanResizeHeight(true)
    border:Resize(actions_column:Width(), actions_column:Height())

    border:SetDockingPoint(5)
    border:SetDockOffset(0, 0)

    -- plop in the title track
    local title = core:get_or_create_component("title", "ui/templates/panel_subtitle", dummy)
    title:Resize(dummy:Width() * 0.9, title:Height())
    title:SetDockingPoint(2)
    title:SetDockOffset(0, title:Height() * 0.1)

    -- create the actual text for the title
    local title_text = core:get_or_create_component("text", "ui/vandy_lib/text/la_gioconda/center", title)
    title_text:SetVisible(true)

    title_text:SetDockingPoint(5)
    title_text:SetDockOffset(0, 0)
    title_text:Resize(title:Width() * 0.9, title:Height() * 0.9)

    do -- resize stuff to make the title not stretchy or ugggggo
        local w,h = title_text:TextDimensionsForText("Actions & Upgrades")
        title_text:ResizeTextResizingComponentToInitialSize(w, h)
        title_text:SetStateText("[[col:fe_white]]Actions & Upgrades[[/col]]")
    end

    -- create the category holder in the center of the parchment

    -- get the remaining height available in the left column; -25 is for a 5px margin on top and bottom (and the -15 offset for the bottom background)
    local remaining_height = dummy:Height() - title:Height() - 25

    -- set the holder to -20 of the dummy, again for 10px margins on left/right
    local remaining_width = dummy:Width() - 20

    local categories_holder = core:get_or_create_component("categories_holder", "ui/vandy_lib/script_dummy", dummy)
    categories_holder:SetDockingPoint(2)
    categories_holder:SetDockOffset(0, title:Height() + 5)

    categories_holder:Resize(remaining_width, remaining_height)

    local i_to_docking_point = {
        [1] = 1, -- top left
        [2] = 3, -- top right
        [3] = 7, -- bottom left
        [4] = 9, -- bottom right
    }

    local index_to_image = {
        [1] = "pressed",
        [2] = "hover",
        [3] = "active",
        [4] = "inactive",
        [5] = "underlay",
    }

    local colors = {
        "yellow",
        "weapon",
        "purple",
        "orange",
        "green",
        "blue",
        "flask",
        "bag",
        "arrow",
        "bag",
        "armour",
    }

    local categories = bmm:get_categories()
    local i = 1

    -- loop through and create each individual category header
    for category_key, category_data in pairs(categories) do
        local docking_point_for_i = i_to_docking_point[i]
        i = i + 1

        local category_image_path = category_data.img_path
        local category_text_string = effect.get_localised_string(category_data.text_string)

        --local upgrade_keys = category_data.upgrades
        local action_keys = category_data.actions

        -- create the positioning component to hold everything for this category
        local category_holder = core:get_or_create_component(category_key.."_holder", "ui/vandy_lib/script_dummy", categories_holder)

        -- make it a rough rectangle set on one of the four corners
        category_holder:Resize(categories_holder:Width() * 0.48, categories_holder:Height() * 0.48)
        category_holder:SetDockingPoint(docking_point_for_i)
        category_holder:SetDockOffset(0, 0)

        local category_title = core:get_or_create_component("title", "ui/vandy_lib/banner_with_text", category_holder)
        category_title:SetStateText(category_text_string)
        category_title:SetDockingPoint(2)
        category_title:SetDockOffset(0, 0)

        -- create the image for the category
        local category_uic = core:get_or_create_component(category_key..
        "_img", "ui/templates/custom_image", category_holder)
        category_uic:SetState("custom_state_1")
        category_uic:SetImagePath(category_image_path)
        category_uic:SetVisible(true)

        local new_w = category_holder:Width() * 0.90
        local new_h = new_w / 3

        category_uic:SetCanResizeWidth(true) category_uic:SetCanResizeHeight(true)
        category_uic:Resize(new_w, new_h)
        category_uic:SetCanResizeWidth(false) category_uic:SetCanResizeHeight(false)

        category_uic:SetDockingPoint(2)
        category_uic:SetDockOffset(0, 5 + category_title:Height())

        local actions_prototype = bmm:get_action_prototype()
        local actions_template = actions_prototype.template_path
        local actions_tt = effect.get_localised_string(actions_prototype.tooltip_string)

        local actions_holder = core:get_or_create_component("action_holder", actions_template, category_holder)
        actions_holder:SetDockingPoint(2)
        actions_holder:SetDockOffset(0, category_uic:Height() + category_title:Height() + 5)
        actions_holder:Resize(category_holder:Width(), category_holder:Height() - category_uic:Height() - category_title:Height())

        actions_holder:SetState("custom_state_2")
        actions_holder:SetImagePath("ui/skins/default/parchment_divider.png", 1)
        actions_holder:SetVisible(true)

        actions_holder:SetTooltipText(actions_tt, true)

        --[[local actions_holder = core:get_or_create_component("actions_holder", actions_template, holder)

        actions_holder:SetDockingPoint(2)
        actions_holder:SetDockOffset(0, 0)
        actions_holder:SetCanResizeWidth(true) actions_holder:SetCanResizeHeight(true)
        actions_holder:Resize(holder:Width(), holder:Height())

        actions_holder:SetTooltipText(actions_tt, true)

        local first = true
        local second = false]]

        -- this assigns a position for "i" index - first is top left corner, second is top right corner, etc
        local i_to_pos = {
            [1] = 1,
            [2] = 3,
            [3] = 7,
            [4] = 9,
        }

        core:add_listener(
            "action_pressed",
            "ComponentLClickUp",
            function(context)
                local uic = UIComponent(context.component)
                return uicomponent_descended_from(uic, "action_holder")
            end,
            function(context)
                local key = context.string
                bmm:log("Action pressed: "..key)

                self:populate_context_menu_on_press(key)
            end,
            true
        )

        for j = 1, #action_keys do
            local action_key = action_keys[j]
            local pos = i_to_pos[j]
            local action_data = bmm:get_action_with_key(action_key)

            bmm:log("Creating action: ["..action_key.."]")

            local action_text = effect.get_localised_string(action_data.text_string)
            local action_tt = effect.get_localised_string(action_data.tooltip_string)
            local action_img = action_data.img_path

            local duration = action_data.duration
            local costs = action_data.cost

            local gold_cost = costs.gold
            local food_cost = costs.food

            local action_holder = core:get_or_create_component("action_holder_"..tostring(j), "ui/vandy_lib/script_dummy", actions_holder)
            action_holder:SetDockingPoint(pos)
            action_holder:SetDockOffset(0, 0)
            action_holder:Resize(actions_holder:Width() / 2, actions_holder:Height() / 2)
            action_holder:SetInteractive(false)

            local action_uic = core:get_or_create_component(action_key, "ui/vandy_lib/buildingframe", action_holder)
            action_uic:SetDockingPoint(5)
            action_uic:SetDockOffset(0, 0)

            action_uic:SetState("built_panel")
            action_uic:SetTooltipText(action_text.."||"..action_tt, true)

            action_uic:SetImagePath(action_img)

            local keep = {
                mouseover_parent = true,
                food_cost = true,
                frame_glow = true,
            }

            for z = 1, action_uic:ChildCount() -1 do
                local child = UIComponent(action_uic:Find(z))
                --local id = child:Id()
                --if not keep[id] then
                    child:SetVisible(false)
                    --self:delete_component(child)
                --end
            end

            local mouseover_parent = UIComponent(action_uic:Find("mouseover_parent"))
            local turns_center = UIComponent(mouseover_parent:Find("turns_corner"))

            mouseover_parent:SetVisible(true)
            turns_center:SetVisible(true)

            turns_center:SetStateText(tostring(duration))

            turns_center:SetTooltipText("Turns this action will be active. Only one action can be active at a time!", true)

            local upgrade_box = UIComponent(mouseover_parent:Find("upgrade-box"))
            local gold_uic = UIComponent(upgrade_box:Find("building_cost"))

            do
                local x,y = gold_uic:GetDockOffset()
                y = y + 15
                gold_uic:SetDockOffset(x, y)
            end

            local player_gold_amount = cm:get_faction(cm:get_local_faction(true)):treasury()

            -- check if the player can even afford this
            if gold_cost > player_gold_amount then
                gold_uic:SetState("red")
                gold_uic:SetStateText(tostring(gold_cost))
            else
                gold_uic:SetState("normal")
                gold_uic:SetStateText(tostring(gold_cost))
            end

            local food_uic = UIComponent(action_uic:Find("food_cost"))
            local food_text_uic = UIComponent(food_uic:Find("dy_food_cost"))

            upgrade_box:SetVisible(true)
            food_uic:SetVisible(true)
            gold_uic:SetVisible(true)

            food_text_uic:SetStateText(tostring(food_cost))
            food_uic:SetImagePath("ui/skins/default/skaven_food_icon.png")

            -- TODO temp disbable
            food_uic:SetVisible(false)
        end

        --[[local upgrades_prototype = bmm:get_upgrade_prototype()
        local upgrades_template = upgrades_prototype.template_path
        local upgrades_tt = effect.get_localised_string(upgrades_prototype.tooltip_string)

        local upgrades_holder = core:get_or_create_component("upgrades_holder", upgrades_template, holder)
        upgrades_holder:SetVisible(true)
        upgrades_holder:SetState("custom_state_2")
        upgrades_holder:SetImagePath("ui/skins/default/parchment_divider.png", 1)

        upgrades_holder:SetDockingPoint(8)
        upgrades_holder:SetDockOffset(0, 0)
        upgrades_holder:SetCanResizeWidth(true) upgrades_holder:SetCanResizeHeight(true)

        upgrades_holder:Resize(holder:Width(), holder:Height() * 0.49)

        upgrades_holder:SetInteractive(true)
        upgrades_holder:SetTooltipText(upgrades_tt, true)

        pos = 4
        for j = 1, #upgrade_keys do
            local upgrade_key = upgrade_keys[j]
            local upgrade_data = bmm:get_upgrade_with_key(upgrade_key)

            local upgrade_text = effect.get_localised_string(upgrade_data.text_string)
            local upgrade_tt = effect.get_localised_string(upgrade_data.tooltip_string)
            local img_path = upgrade_data.img_path

            local upgrade_holder = core:get_or_create_component("upgrade_holder_"..tostring(j), "ui/vandy_lib/script_dummy", upgrades_holder)
            upgrade_holder:SetDockingPoint(pos) 
            pos = pos + 1
            upgrade_holder:SetDockOffset(0, 0)
            upgrade_holder:Resize(actions_holder:Width() / 3, actions_holder:Height())

            local upgrade_uic = core:get_or_create_component(upgrade_key, "ui/vandy_lib/buildingframe", upgrade_holder)
            upgrade_uic:SetDockingPoint(5)
            upgrade_uic:SetDockOffset(0, 0)

            upgrade_uic:SetState("built_panel")
            upgrade_uic:SetTooltipText(upgrade_text.."||"..upgrade_tt, true)

            upgrade_uic:SetImagePath(img_path)

            for z = 1, upgrade_uic:ChildCount() -1 do
                local child = UIComponent(upgrade_uic:Find(z))
                child:SetVisible(false)
            end
        end]]
    end
    bmm:log("Actions column created!")
end

function ui_obj:create_broodmother_column()
    local panel = find_uicomponent(self.panel_name)
    local broodmother_column = find_uicomponent(panel, "broodmother_column")
    local img_path = effect.get_skinned_image_path("parchment_texture.png")

    local dummy = core:get_or_create_component("dummy", "ui/vandy_lib/custom_image_tiled", broodmother_column)
    dummy:SetVisible(true)
    dummy:SetState('custom_state_2')
    dummy:SetImagePath(img_path, 1)
    dummy:SetCanResizeWidth(true) dummy:SetCanResizeHeight(true)
    dummy:Resize(broodmother_column:Width(), broodmother_column:Height())

    dummy:SetDockingPoint(5)
    dummy:SetDockOffset(0, 0)

    -- add the four large buttons
    local button_holder = core:get_or_create_component("broodmother_holder", "ui/vandy_lib/custom_image_tiled", dummy)
    button_holder:SetDockingPoint(2)
    button_holder:SetDockOffset(0, 10)

    button_holder:SetVisible(true)
    button_holder:SetState('custom_state_2')
    button_holder:SetImagePath("ui/skins/default/panel_back_tile.png", 1)

    button_holder:SetCanResizeWidth(true) button_holder:SetCanResizeHeight(true)
    button_holder:Resize(dummy:Width() * 0.9, dummy:Height() * 0.4)

    local border = core:get_or_create_component("border", "ui/vandy_lib/custom_image_tiled", button_holder)
    border:SetDockingPoint(5)
    border:SetDockOffset(0, 0)

    border:SetVisible(true)
    border:SetState('custom_state_2')
    border:SetImagePath("ui/skins/wh_main_vmp_vampire_counts/panel_back_border.png", 1)

    border:SetCanResizeWidth(true) border:SetCanResizeHeight(true)
    border:Resize(button_holder:Width(), button_holder:Height())

    local parent_height = button_holder:Height()
    local parent_width = button_holder:Width()

    local h_pos = 0
    local h_gap = 0
    local all_button_height = 0

    -- index 0: icon_end_turn.png
    -- index 1: pressed.png
    -- index 2: hover.png
    -- index 3: active.png
    -- index 4: inactive.png

    local image_paths = {
        "Broodmama_option_selected.png",
        "Broodmama_option_hover.png",
        "Broodmama_option_active.png",
        "Broodmama_option_inactive.png",
    }

    local prefix = "ui/broodmother/"

    local i_to_image_paths = {
        {"ui/broodmother/Broodmama_option_eshin.png"},
        {"ui/broodmother/Broodmama_option_moulder.png"},
        {"ui/broodmother/Broodmama_option_pestilens.png"},
        {"ui/broodmother/Broodmama_option_skryre.png"},
        {"ui/broodmother/Broodmama_option_static.png", "ui/broodmother/Broodmama_option_selected.png", "ui/broodmother/Broodmama_option_hover.png"},
    }

    local i_to_docking_point = {
        1, 3, 7, 9
    }
    
    local i_to_offset = {
        {20, 20},
        {-20, 20},
        {20, -20}, 
        {-20, -20},
    }

    local broodmothers = bmm:get_broodmothers_for_faction(cm:get_local_faction(true))

    local locked = false
    local active = true

    local slots = bmm:get_slots()

    for i = 1, #slots do
        local test_broodmother = broodmothers[i]

        local slot_state = slots[i]

        local broodmother_holder = nil
        local broodmother_uic = nil

        bmm:log("creating slot num: slot_"..tostring(i))
        broodmother_holder = core:get_or_create_component("slot_"..tostring(i), "ui/vandy_lib/script_dummy", button_holder)
        broodmother_holder:Resize(button_holder:Width() * 0.5, button_holder:Height() * 0.5)
        broodmother_holder:SetDockingPoint(i_to_docking_point[i])
        
        -- check if this is an empty slot or a filled one
        if test_broodmother then
            local broodmother_key = test_broodmother:get_key()
            bmm:log(broodmother_key)

            self.slots[i] = broodmother_key

            broodmother_uic = core:get_or_create_component(broodmother_key, "ui/broodmother/templates/broodmother_icon", broodmother_holder)

            --broodmother_uic:SetImagePath("ui/skins/default/1x1_transparent_white.png", 0)
            local img_path = test_broodmother:get_base_image()
            bmm:log(img_path)

            broodmother_uic:SetImagePath(img_path, 0)

            -- overwrite the "active" image 
            --[[for j = 1, #image_paths do
                broodmother_uic:SetImagePath(prefix .. "Broodmama_open_slot.png", j)
            end]]

            broodmother_uic:SetState("active")

            --[[if active then
                broodmother_uic:SetState("active")
                active = false
            else
                broodmother_uic:SetState("inactive")
                active = true
            end]]

            self:add_listener("select_broodmother")
            core:add_listener(
                "select_broodmother",
                "ComponentLClickUp",
                function(context)
                    return context.string == broodmother_key
                end,
                function(context)
                    self:populate_panel_on_broodmother_selected(i)
                end,
                true
            )
        else
            broodmother_uic = core:get_or_create_component("empty_slot", "ui/broodmother/templates/broodmother_icon", broodmother_holder)

            self.slots[i] = slot_state

            bmm:log(slot_state)
            -- set it as locked or open
            if slot_state == "locked" then
                broodmother_uic:SetState(slot_state)
                broodmother_uic:SetTooltipText("[[col:red]]This slot is currently locked! It will be unlocked when this mod is more completed. :)[[/col]]", true)
            else
                broodmother_uic:SetState(slot_state)
                broodmother_uic:SetTooltipText("Open Slot", true)
            end
        end

        -- set the size to 2.4x larger
        broodmother_uic:SetCanResizeWidth(true) broodmother_uic:SetCanResizeHeight(true)
        broodmother_uic:Resize(broodmother_uic:Width() * 2.4, broodmother_uic:Height() * 2.4)
        broodmother_uic:SetCanResizeWidth(false) broodmother_uic:SetCanResizeHeight(false)

        broodmother_uic:SetDockingPoint(5)
        broodmother_uic:SetDockOffset(0, 0)
    end

    -- add the broodmother details panel at the bottom
    -- has: location, name, traits


    local broodmother_details = core:get_or_create_component("broodmother_details", "ui/vandy_lib/custom_image_tiled", dummy)
    broodmother_details:SetVisible(true)
    broodmother_details:SetState("custom_state_2")
    broodmother_details:SetImagePath("ui/skins/default/panel_back_border.png", 1)

    broodmother_details:SetDockingPoint(8)
    broodmother_details:SetDockOffset(0, -5)

    broodmother_details:SetCanResizeWidth(true) broodmother_details:SetCanResizeHeight(true)
    broodmother_details:Resize(dummy:Width() * 0.95, dummy:Height() * 0.58)

    local broodmother_title = core:get_or_create_component("broodmother_title", "ui/templates/panel_subtitle", broodmother_details)
    broodmother_title:Resize(broodmother_details:Width() * 0.9, broodmother_title:Height())
    broodmother_title:SetDockingPoint(2)
    broodmother_title:SetDockOffset(0, 10)

    local name = core:get_or_create_component("name", "ui/vandy_lib/text/la_gioconda/center", broodmother_title)
    name:SetVisible(true)
    name:SetStateText("")
    
    name:SetDockingPoint(5)
    name:SetDockOffset(0, 0)
    name:Resize(broodmother_title:Width() * 0.9, broodmother_title:Height() * 0.9)

    local broodmother_location = core:get_or_create_component("broodmother_location", "ui/vandy_lib/text/la_gioconda_uppercase", broodmother_details)
    broodmother_location:SetStateText("")
    broodmother_location:SetVisible(true)
    
    broodmother_location:SetCanResizeWidth(true) broodmother_location:SetCanResizeHeight(true)
    broodmother_location:Resize(broodmother_details:Width() * 0.95, broodmother_location:Height() * 0.9)
    broodmother_location:SetDockingPoint(2)
    broodmother_location:SetDockOffset(0, 10 + broodmother_title:Height())

    local div = core:get_or_create_component("hbar", "ui/templates/custom_image", broodmother_location)
    div:SetVisible(true)
    div:SetState("custom_state_1")
    div:SetImagePath("ui/skins/default/separator_skull2.png")

    div:SetCanResizeHeight(true) div:SetCanResizeWidth(true)
    div:Resize(321, 14)
    div:SetCanResizeHeight(false) div:SetCanResizeWidth(false)

    div:SetDockingPoint(8)
    div:SetDockOffset(0, 15)

    -- TODO add in a proper title a la the character details sheet    
    local traits_panel = core:get_or_create_component("traits_panel", "ui/vandy_lib/custom_image_tiled", broodmother_details)
    traits_panel:SetVisible(true)
    traits_panel:SetState("custom_state_2")
    traits_panel:SetImagePath("ui/skins/default/parchment_divider.png", 1)

    traits_panel:SetDockingPoint(2)
    traits_panel:SetDockOffset(0, broodmother_title:Height() + broodmother_location:Height() + div:Height() + 20)
    traits_panel:Resize(broodmother_details:Width(), broodmother_details:Height() * 0.4)
    
    local text = core:get_or_create_component("dummy_text", "ui/vandy_lib/text/la_gioconda/unaligned", traits_panel)
    text:SetVisible(true)

    text:SetDockingPoint(2)
    text:SetDockOffset(0, 10)

    local w,h = text:TextDimensionsForText("Broodmother Traits")
    text:ResizeTextResizingComponentToInitialSize(w,h)
    text:SetStateText("Broodmother Traits")

    local list_view = core:get_or_create_component("list_view", "ui/vandy_lib/vlist", traits_panel)
    list_view:SetDockingPoint(2)
    list_view:SetDockOffset(10, text:Height() + 5)

    local remaining_width = traits_panel:Width()
    local remaining_height = traits_panel:Height() - text:Height()

    list_view:SetCanResizeWidth(true) list_view:SetCanResizeHeight(true)
    list_view:Resize(remaining_width -30, remaining_height -30)

    local list_clip = find_uicomponent(list_view, "list_clip")
    list_clip:SetCanResizeWidth(true) list_clip:SetCanResizeHeight(true)
    list_clip:SetDockingPoint(0)
    list_clip:SetDockOffset(0, 0)
    list_clip:Resize(remaining_width, remaining_height)

    local list_box = find_uicomponent(list_clip, "list_box")
    list_box:SetCanResizeWidth(true) list_box:SetCanResizeHeight(true)
    list_box:SetDockingPoint(1)
    list_box:SetDockOffset(0, 0)
    list_box:Resize(remaining_width, remaining_height)

    local l_handle = find_uicomponent(list_view, "vslider")
    l_handle:SetDockingPoint(6)
    l_handle:SetDockOffset(-20, 0)

    local effects_holder = core:get_or_create_component("effects_holder", "ui/vandy_lib/custom_image_tiled", broodmother_details)
    effects_holder:SetVisible(true)
    effects_holder:SetCanResizeWidth(true) effects_holder:SetCanResizeHeight(true)
    effects_holder:Resize(broodmother_details:Width() * 0.95, broodmother_details:Height() * 0.4)
    effects_holder:SetCanResizeWidth(false) effects_holder:SetCanResizeHeight(false)

    effects_holder:SetState("custom_state_2")
    effects_holder:SetDockingPoint(8)
    effects_holder:SetDockOffset(0, -10)

    effects_holder:SetImagePath("ui/skins/warhammer2/parchment_divider.png", 1)

    --[[local div = core:get_or_create_component("div", "ui/templates/custom_image", effects_holder)
    div:SetVisible(true)
    div:SetCanResizeWidth(true) div:SetCanResizeHeight(true)
    div:Resize(6, effects_holder:Height() * 0.98)
    div:SetCanResizeWidth(false) div:SetCanResizeHeight(false)

    div:SetState("custom_state_1")
    div:SetImagePath("ui/skins/warhammer2/slider_vertical_mid.png", 0)

    div:SetDockingPoint(5)
    div:SetDockOffset(0, 0)]]

    bmm:log("broodmother column created")
end

function ui_obj:create_context_column()
    bmm:log("creating context column")
    local panel = find_uicomponent(self.panel_name)
    local context_column = find_uicomponent(panel, "context_column")
    local img_path = effect.get_skinned_image_path("parchment_texture.png")

    bmm:log("creating dummy")
    local dummy = core:get_or_create_component("dummy", "ui/vandy_lib/custom_image_tiled", context_column)
    bmm:log("created")

    dummy:SetVisible(true)
    dummy:SetState('custom_state_2')
    dummy:SetImagePath(img_path, 1)
    dummy:SetCanResizeWidth(true) dummy:SetCanResizeHeight(true)
    dummy:Resize(context_column:Width(), context_column:Height())

    dummy:SetDockingPoint(5)
    dummy:SetDockOffset(0, 0)

    local h_diff = (dummy:Height() * 0.01) / 2

    bmm:log("creating rites_holder")
    local rites_holder = core:get_or_create_component("rites_holder", "ui/vandy_lib/script_dummy", dummy)
    bmm:log("done")

    rites_holder:Resize(dummy:Width(), dummy:Height())
    rites_holder:SetDockingPoint(2)
    rites_holder:SetDockOffset(0, (h_diff/2))

    bmm:log("creating rites_title")
    local rites_title = core:get_or_create_component("rites_title", "ui/vandy_lib/text/la_gioconda/center", rites_holder)
    bmm:log("done") 

    rites_title:Resize(rites_holder:Width() * 0.95, rites_title:Height())
    rites_title:SetDockingPoint(2)
    rites_title:SetDockOffset(0, 10)

    do
        local w,h = rites_title:TextDimensionsForText("Currently Selected Action")
        rites_title:ResizeTextResizingComponentToInitialSize(w, h)
        rites_title:SetStateText("Currently Selected Action")
    end

    bmm:log("creating hbar")
    local div = core:get_or_create_component("hbar", "ui/templates/custom_image", rites_title)
    bmm:log("done")

    div:SetVisible(true)
    div:SetState("custom_state_1")
    div:SetImagePath("ui/skins/default/separator_skull2.png")

    div:SetCanResizeHeight(true) div:SetCanResizeWidth(true)
    div:Resize(321, 14)
    div:SetCanResizeHeight(false) div:SetCanResizeWidth(false)

    div:SetDockingPoint(8)
    div:SetDockOffset(0, 15)

    bmm:log("creating rites_flavour")
    local rites_flavour = core:get_or_create_component("rites_flavour", "ui/vandy_lib/text/georgia_italic_with_background", rites_holder)
    bmm:log("done")

    rites_flavour:SetVisible(true)

    rites_flavour:SetCanResizeWidth(true) rites_flavour:SetCanResizeHeight(true)
    rites_flavour:Resize(rites_holder:Width() * 0.8, rites_title:Height() * 8)

    rites_flavour:SetDockingPoint(2)
    rites_flavour:SetDockOffset(0, rites_title:Height() + 25)
    
    do
        local w,h = rites_flavour:TextDimensionsForText("Flavour text is located here, sir.")
        rites_flavour:ResizeTextResizingComponentToInitialSize(w, h)
        rites_flavour:SetStateText("Flavour text is located here, sir.")
    end

    bmm:log("deets_holder")
    local deets_holder = core:get_or_create_component("deets_holder", "ui/vandy_lib/script_dummy", rites_holder)
    bmm:log("done")

    deets_holder:Resize(dummy:Width(), dummy:Height() * 0.1)
    deets_holder:SetDockingPoint(2)
    deets_holder:SetDockOffset(0, rites_flavour:Height() + rites_title:Height() + 25)

    -- hold gold and food cost on the left, and the cooldown and duration on the right
    local gold_holder = core:get_or_create_component("gold_holder", "ui/vandy_lib/cost_holder", deets_holder)
    gold_holder:SetDockingPoint(2)
    gold_holder:SetDockOffset(-75, 0)
    gold_holder:SetTooltipText("Gold cost||The cost in gold, duh.", true)

    do
        local icon = find_uicomponent(gold_holder, "icon")
        icon:SetImagePath("ui/skins/default/icon_treasury.png")
    end

    local food_holder = core:get_or_create_component("food_holder", "ui/vandy_lib/cost_holder", deets_holder)
    food_holder:SetDockingPoint(2)
    food_holder:SetDockOffset(-75, 40)
    food_holder:SetTooltipText("Food cost||The cost in food.", true)

    do
        local icon = find_uicomponent(food_holder, "icon")
        icon:SetImagePath("ui/skins/default/skaven_food_icon.png")
    end

    local duration_holder = core:get_or_create_component("duration_holder", "ui/vandy_lib/cost_holder", deets_holder)
    duration_holder:SetDockingPoint(2)
    duration_holder:SetDockOffset(75, 0)
    duration_holder:SetTooltipText("Duration||Blep", true)

    do
        local icon = find_uicomponent(duration_holder, "icon")
        icon:SetImagePath("ui/skins/default/icon_hourglass.png")
    end

    local cooldown_holder = core:get_or_create_component("cooldown_holder", "ui/vandy_lib/cost_holder", deets_holder)
    cooldown_holder:SetDockingPoint(2)
    cooldown_holder:SetDockOffset(75, 40)
    cooldown_holder:SetTooltipText("Cooldown Time||Blerp.", true)

    do
        local icon = find_uicomponent(cooldown_holder, "icon")
        icon:SetImagePath("ui/skins/default/icon_cooldown_26.png")
    end

    local buttons_holder = core:get_or_create_component("buttons_holder", "ui/vandy_lib/script_dummy", rites_holder)
    buttons_holder:SetDockingPoint(8)
    buttons_holder:SetDockOffset(0, 0)
    buttons_holder:Resize(dummy:Width() * 0.9, dummy:Height() * 0.05)

    do
        local perform_button = core:get_or_create_component("perform", "ui/templates/square_large_text_button", buttons_holder)
        perform_button:SetDockingPoint(5)
        perform_button:SetDockOffset(0, 0)

        perform_button:SetState("active")

        local txt = UIComponent(perform_button:Find("button_txt"))
        txt:SetStateText("Perform")
    end

    local effects_holder = core:get_or_create_component("effects_holder", "ui/vandy_lib/custom_image_tiled", rites_holder)
    effects_holder:SetVisible(true)
    effects_holder:SetState("custom_state_2")
    effects_holder:SetImagePath("ui/skins/warhammer2/parchment_divider.png", 1)
    effects_holder:SetDockingPoint(2)
    
    local remaining_height = dummy:Height() - deets_holder:Height() - rites_flavour:Height() - rites_title:Height() - buttons_holder:Height() - 30 
    effects_holder:Resize(dummy:Width() * 0.9, remaining_height)
    effects_holder:SetDockOffset(0, deets_holder:Height() + rites_flavour:Height() + rites_title:Height() + 15)
    
    --[[local text = core:get_or_create_component("test", "ui/vandy_lib/text/la_gioconda/unaligned", effects_holder)
    text:SetDockingPoint(1)
    text:SetDockOffset(5, 0)
    text:SetStateText("This is my effect text.")]]

    --[[local costs_holder = core:get_or_create_component("costs_holder", "ui/vandy_lib/script_dummy", dummy)
    costs_holder:Resize(dummy:Width(), dummy:Height() * 0.29)
    costs_holder:SetDockingPoint(8)
    costs_holder:SetDockOffset(0, -(h_diff/2))

    local costs_title = core:get_or_create_component("costs_title", "ui/vandy_lib/text/la_gioconda", costs_holder)
    costs_title:SetVisible(true)

    costs_title:SetCanResizeWidth(true) costs_title:SetCanResizeHeight(true)
    costs_title:Resize(costs_title:Width() * 1.5, costs_title:Height() * 1.5)

    costs_title:SetDockingPoint(2)
    costs_title:SetDockOffset(0, costs_title:Height() + 20)
    
    do
        local w,h = costs_title:TextDimensionsForText("Passive costs per turn:")
        costs_title:ResizeTextResizingComponentToInitialSize(w, h)
        costs_title:SetStateText("Passive costs per turn:")
    end]]

    bmm:log("context menu created")
end

function ui_obj:populate_panel_on_broodmother_selected(slot_num)
    bmm:log("Populating on broodmother selected!")

    self.selected_slot = slot_num
    local slots = self.slots

    local broodmother_key = slots[slot_num]
    local broodmother_obj = bmm:get_broodmother_with_key(broodmother_key)

    local panel = find_uicomponent(self.panel_name)
    local broodmother_column = find_uicomponent(panel, "broodmother_column")
    local broodmother_holder = find_uicomponent(broodmother_column, "dummy", "broodmother_holder")
    local broodmother_details = find_uicomponent(broodmother_column, "dummy", "broodmother_details")
    local broodmother_title = find_uicomponent(broodmother_details, "broodmother_title", "name")
    local broodmother_location = find_uicomponent(broodmother_details, "broodmother_location")

    local traits_panel = find_uicomponent(broodmother_column, "traits_panel")
    local list_box = find_uicomponent(traits_panel, "list_view", "list_clip", "list_box")

    -- set the broodmother name on the title bar
    local broodmother_name = broodmother_obj:get_name()
    self:set_state_text_with_resize(broodmother_title, "[[col:fe_white]]"..broodmother_name.."[[/col]]")

    -- set the broodmother location text
    local location = broodmother_obj:get_location() -- location is a region_key; must be localised!
    local location_text = effect.get_localised_string("regions_onscreen_"..location)
    self:set_state_text_with_resize(broodmother_location, "Location: "..location_text)

    -- set all other broodmothers to their proper states
    for j = 1, #slots do
        local slot = slots[j]
        bmm:log("checking slot num "..tostring(j))
        bmm:log(slot)

        if slot == "open" or slot == "locked" then
            -- do nothing?
        else
            bmm:log("getting slot uic")
            local slot_uic = find_uicomponent(broodmother_holder, "slot_"..tostring(j))
            bmm:log("is uic: "..tostring(is_uicomponent(slot_uic)))
            local broodmother_uic = UIComponent(slot_uic:Find(0))
            bmm:log("getting broodmama uic: "..tostring(is_uicomponent(broodmother_uic)))

            if j == slot_num then
                bmm:log("at currently selected, setting down")
                broodmother_uic:SetState("down")
            else
                bmm:log("setting active")
                broodmother_uic:SetState("active")
            end
        end
    end

    -- clear any extant traits
    list_box:DestroyChildren()

    --local template_path = "ui/broodmother/templates/"

    -- add in all the traits for this broodie
    local traits = broodmother_obj:get_traits()

    for i = 1, #traits do
        bmm:log("Creating trait img "..traits[i])

        local trait_key = traits[i]

        local trait_data = bmm._data.traits[trait_key]
        if not trait_data then
            bmm:log("ERROR TRAIT NOT FOUND ["..trait_key.."]")
        else

            local trait_holder = core:get_or_create_component(trait_key, "ui/vandy_lib/custom_image_tiled", list_box)
            trait_holder:SetVisible(true)
            trait_holder:SetInteractive(true)

            trait_holder:SetState("custom_state_2")
            trait_holder:SetImagePath("ui/skins/default/parchment_button_square_hover.png", 1)
            trait_holder:SetCanResizeWidth(true) trait_holder:SetCanResizeHeight(true)
            trait_holder:Resize(list_box:Width() * 0.9, list_box:Height() * 0.20)

            trait_holder:SetDockingPoint(1)
            trait_holder:SetDockOffset(0, 0)

            local trait_uic = core:get_or_create_component(trait_key, "ui/vandy_lib/text/text_with_icon", trait_holder)
            trait_uic:SetVisible(true)
            trait_uic:SetInteractive(false)
            trait_uic:SetDockingPoint(4)
            trait_uic:SetDockOffset(0, 0)

            local eb = trait_data["effect_bundle"]
            local eb_key = eb.key

            local eb_text = effect.get_localised_string("effect_bundles_localised_title_"..eb_key)
            local eb_description = effect.get_localised_string("effect_bundles_localised_description_"..eb_key)

            local eb_icon = eb.image_path

            trait_uic:SetStateText(eb_text)
            trait_uic:SetImagePath(eb_icon)
            
            local effects = eb.effects

            local is_hovered = false

            self:add_listener("bm_trait_hover")
            core:add_listener(
                "bm_trait_hover",
                "ComponentMouseOn",
                function(context)
                    return context.string == trait_key
                end,
                function(context)
                    is_hovered = true

                    local tooltip = core:get_or_create_component("bm_trait_tooltip", "ui/campaign ui/character_background_skill_tooltip")
                    tooltip:SetVisible(true)

                    local uic_title = find_uicomponent(tooltip, "dy_title")
                    local uic_desc = find_uicomponent(tooltip, "description_window")
                    local uic_expl = find_uicomponent(tooltip, "dy_explanation") -- TODO use this???

                    uic_title:SetStateText(eb_text)
                    uic_desc:SetStateText(eb_description)

                    local effects_list = find_uicomponent(tooltip, "effects_list")
                    local template_entry = find_uicomponent(effects_list, "template_entry")

                    for j = 1, #effects do
                        bmm:log("in effect ["..j.."]")
                        local current_effect = effects[j]

                        local effect_key = current_effect.key
                        local value = current_effect.value
                        local image_path = current_effect.image_path
                        local effect_scope = current_effect.effect_scope
                        local is_good = current_effect.is_good

                        bmm:log("bloop")

                        local effect_uic = UIComponent(template_entry:CopyComponent(effect_key))

                        local effect_text = effect.get_localised_text("effects_description_"..effect_key) .. " " .. effect.get_localised_text("campaign_effect_scopes_localised_text_"..effect_scope)

                        if is_good then
                            effect_text = "[[col:dark_g]]" .. effect_text .. "[[/col]]"
                        else
                            effect_text = "[[col:dark_r]]" .. effect_text .. "[[/col]]"
                        end

                        bmm:log("blep")

                        local val_txt = tostring(value)
                        local plus_val_txt = val_txt
                        if value > 0 then
                            plus_val_txt = "+"..val_txt
                        end


                        if string.find(effect_text, "%+n") then
                            effect_text = string.gsub(effect_text, "%%%+n", plus_val_txt)
                        else
                            if string.find(effect_text, "%n") then
                                effect_text = string.gsub(effect_text, "%%n", val_txt)
                            end
                        end

                        bmm:log("blip")

                        effect_uic:SetVisible(true)
                        effect_uic:SetImagePath(image_path)
                        effect_uic:SetStateText(effect_text)

                        bmm:log("BLAP")
                    end

                    bmm:log("Loop survived!")
                end,
                true
            )

            self:add_listener("bm_trait_hover_off")
            core:add_listener(
                "bm_trait_hover_off",
                "ComponentMouseOn",
                function(context)
                    return is_hovered and context.string ~= trait_key
                end,
                function(context)
                    is_hovered = false

                    local tooltip = find_uicomponent("bm_trait_tooltip")
                    self:delete_component(tooltip)
                end,
                true
            )

        end
    end

    list_box:Layout()
end

function ui_obj:create_panel()
    -- add it - the ui/vandy_lib/frame is a UIC layout file, based off of the Graphics Options frame
    local panel = core:get_or_create_component(self.panel_name, "ui/vandy_lib/frame")
    panel:SetVisible(true)

    -- resize the panel
    local sx, sy = core:get_screen_resolution()
    panel:SetCanResizeWidth(true) panel:SetCanResizeHeight(true)
    panel:Resize(sx * 0.92, sy * 0.92)

    -- edit the name
    local title_plaque = find_uicomponent(panel, "title_plaque")
    local title = find_uicomponent(title_plaque, "title")
    title:SetStateText("Brood Mothers")

    -- hide stuff from the gfx window
    find_uicomponent(panel, "checkbox_windowed"):SetVisible(false)
    find_uicomponent(panel, "ok_cancel_buttongroup"):SetVisible(false)
    find_uicomponent(panel, "button_advanced_options"):SetVisible(false)
    find_uicomponent(panel, "button_recommended"):SetVisible(false)
    find_uicomponent(panel, "dropdown_resolution"):SetVisible(false)
    find_uicomponent(panel, "dropdown_quality"):SetVisible(false)

    -- create the close button
    local close_button_uic = core:get_or_create_component("button_close", "ui/templates/round_medium_button", panel)
    local img_path = effect.get_skinned_image_path("icon_cross.png")
    close_button_uic:SetImagePath(img_path)
    close_button_uic:SetTooltipText("Close panel", true)

    -- bottom center
    close_button_uic:SetDockingPoint(8)
    close_button_uic:SetDockOffset(0, -5)

    -- close button functionality
    self:add_listener("close_broodmama")
    core:add_listener(
        "close_broodmama",
        "ComponentLClickUp",
        function(context)
            return context.string == "button_close"
        end,
        function(context)
            self:close_frame()
        end,
        false
    )

    -- get the width and height of the main background image, not including the title and the bottom bar.
    -- needed for the individual columns n' stuff
    local panel_w, panel_h = panel:Dimensions()
    local pw, ph = panel_w - 10, panel_h - 50 - 75 

    -- parchment always starts 50px down from the top border
    -- parchment is in line with the top border
    local panel_x, panel_y = panel:Position()
    local py = panel_y + 50
    local px = panel_x - 10

    -- create the left column, center column, and right column UICs

    -- this is the gap in the white space around each panel
    local gap = (pw * 0.05) / 4

    local context_column = core:get_or_create_component("context_column", "ui/vandy_lib/script_dummy", panel)
    context_column:Resize(pw * 0.25, ph)
    context_column:SetDockingPoint(1)
    context_column:SetDockOffset(gap, 50)

    local actions_column = core:get_or_create_component("actions_column", "ui/vandy_lib/script_dummy", panel)
    actions_column:Resize(pw * 0.45, ph)
    actions_column:SetDockingPoint(2)
    actions_column:SetDockOffset(0, 50)  

    local broodmother_column = core:get_or_create_component("broodmother_column", "ui/vandy_lib/script_dummy", panel)
    broodmother_column:Resize(pw * 0.25, ph)
    broodmother_column:SetDockingPoint(3)
    broodmother_column:SetDockOffset(-gap, 50)

    -- catch any errors with creating the three columns
    local ok, err = pcall(function()
    self:create_actions_column()
    self:create_broodmother_column()
    self:create_context_column()

    self:populate_panel_on_broodmother_selected(1)
    end) if not ok then bmm:error(err) end

    -- TODO make sure this doesn't break when there are no bm's
    -- auto-select the first slot

end


return ui_obj