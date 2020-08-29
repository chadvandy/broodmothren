local bmm = broodmama_manager

local ui_obj = {
    panel_name = "broodmothers_panel",

    listener_names = {},
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
    local title_text = core:get_or_create_component("text", "ui/vandy_lib/text/la_gioconda", title)
    title_text:SetVisible(true)

    title_text:SetDockingPoint(5)
    title_text:SetDockOffset(0, 0)
    title_text:Resize(title:Width() * 0.9, title:Height() * 0.9)

    do -- resize stuff to make the title not stretchy or ugggggo
        local w,h = title_text:TextDimensionsForText("My City Name")
        title_text:ResizeTextResizingComponentToInitialSize(w, h)
        title_text:SetStateText("[[col:fe_white]]My City Name[[/col]]")
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

        local upgrade_keys = category_data.upgrades
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

        local holder = core:get_or_create_component("holder", "ui/vandy_lib/script_dummy", category_holder)
        holder:SetDockingPoint(2)
        holder:SetDockOffset(0, category_uic:Height() + category_title:Height() + 5)
        holder:Resize(category_holder:Width(), category_holder:Height() - category_uic:Height() - category_title:Height())

        local actions_prototype = bmm:get_action_prototype()
        local actions_template = actions_prototype.template_path
        local actions_tt = effect.get_localised_string(actions_prototype.tooltip_string)

        local actions_holder = core:get_or_create_component("actions_holder", actions_template, holder)
        actions_holder:SetVisible(true)
        actions_holder:SetState("custom_state_2")
        actions_holder:SetImagePath("ui/skins/default/parchment_divider.png", 1)

        actions_holder:SetDockingPoint(2)
        actions_holder:SetDockOffset(0, 0)
        actions_holder:SetCanResizeWidth(true) actions_holder:SetCanResizeHeight(true)
        actions_holder:Resize(holder:Width(), holder:Height() * 0.49)

        actions_holder:SetTooltipText(actions_tt, true)

        local first = true
        local second = false

        local pos = 4
        for j = 1, #action_keys do
            local action_key = action_keys[j]
            local action_data = bmm:get_action_with_key(action_key)

            local action_text = effect.get_localised_string(action_data.text_string)
            local action_tt = effect.get_localised_string(action_data.tooltip_string)
            local action_img = action_data.img_path

            local action_holder = core:get_or_create_component("action_holder_"..tostring(j), "ui/vandy_lib/script_dummy", actions_holder)
            action_holder:SetDockingPoint(pos) 
            pos = pos + 1
            action_holder:SetDockOffset(0, 0)
            action_holder:Resize(actions_holder:Width() / 3, actions_holder:Height())

            local action_uic = core:get_or_create_component(action_key, "ui/vandy_lib/buildingframe", action_holder)
            action_uic:SetDockingPoint(5)
            action_uic:SetDockOffset(0, 0)

            action_uic:SetState("built_panel")
            action_uic:SetTooltipText(action_text.."||"..action_tt, true)

            action_uic:SetImagePath(action_img)

            for z = 1, action_uic:ChildCount() -1 do
                local child = UIComponent(action_uic:Find(z))
                child:SetVisible(false)
            end
        end

        local upgrades_prototype = bmm:get_upgrade_prototype()
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

        local new_pos = 4
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
        end
    end
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

    local index = 4

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

    for i = 1, index do
        local test_broodmother = broodmothers[i]

        local broodmother_key = "broodmother_"..tostring(i)

        -- check if there's a broodmother for this slot; if not, set it inactive and what not
        --if test_broodmother then

        local broodmother_holder = core:get_or_create_component(broodmother_key, "ui/vandy_lib/script_dummy", button_holder)
        broodmother_holder:Resize(button_holder:Width() * 0.5, button_holder:Height() * 0.5)
        broodmother_holder:SetDockingPoint(i_to_docking_point[i])

        local broodmother_uic = core:get_or_create_component(broodmother_key, "ui/broodmother/templates/broodmother_icon", broodmother_holder)
        --broodmother_uic:SetImagePath("ui/skins/default/1x1_transparent_white.png", 0)
        local num = cm:random_number(4, 1)
        broodmother_uic:SetImagePath("ui/broodmother/Broodmama_generic_"..tostring(num).."_inactive.png", 0)

        -- overwrite the "active" image 
        --[[for j = 1, #image_paths do
            broodmother_uic:SetImagePath(prefix .. "Broodmama_open_slot.png", j)
        end]]

        if test_broodmother then
            broodmother_uic:SetState("active")

            self:add_listener("select_broodmother")
            core:add_listener(
                "select_broodmother",
                "ComponentLClickUp",
                function(context)
                    return context.string == broodmother_key
                end,
                function(context)
                    self:populate_panel_on_broodmother_selected(test_broodmother)
                end,
                true
            )
        else
            if locked then
                bmm:log("Setting as locked!")
                broodmother_uic:SetState("locked")
                locked = false
            else
                bmm:log("Setting as open!")
                broodmother_uic:SetState("open")
                locked = true
            end
        end

        -- set the size to 1.4x larger
        broodmother_uic:SetCanResizeWidth(true) broodmother_uic:SetCanResizeHeight(true)
        broodmother_uic:Resize(broodmother_uic:Width() * 1.4, broodmother_uic:Height() * 1.4)
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

    local broodmother_name = core:get_or_create_component("broodmother_name", "ui/templates/panel_subtitle", broodmother_details)
    broodmother_name:Resize(broodmother_details:Width() * 0.9, broodmother_name:Height())
    broodmother_name:SetDockingPoint(2)
    broodmother_name:SetDockOffset(0, 10)
    
    
    local traits_panel = core:get_or_create_component("traits_panel", "ui/vandy_lib/script_dummy", broodmother_details)
    traits_panel:SetDockingPoint(8)
    traits_panel:SetDockOffset(0, -5)
    traits_panel:Resize(broodmother_details:Width(), broodmother_details:Height() * 0.4)
    
    local text = core:get_or_create_component("dummy_text", "ui/vandy_lib/text/la_gioconda", traits_panel)
    text:SetVisible(true)

    text:SetDockingPoint(2)
    text:SetDockOffset(0, 10)

    local w,h = text:TextDimensionsForText("Traits Go Here!")
    text:ResizeTextResizingComponentToInitialSize(w,h)
    text:SetStateText("Traits Go Here!")

    local list_view = core:get_or_create_component("list_view", "ui/vandy_lib/vlist", traits_panel)
    list_view:SetDockingPoint(2)
    list_view:SetDockOffset(10, text:Height() + 5)

    local remaining_width = traits_panel:Width()
    local remaining_height = traits_panel:Height() - text:Height()

    list_view:SetCanResizeWidth(true) list_view:SetCanResizeHeight(true)
    list_view:Resize(remaining_width, remaining_height)

    local list_clip = find_uicomponent(list_view, "list_clip")
    list_clip:SetCanResizeWidth(true) list_clip:SetCanResizeHeight(true)
    list_clip:SetDockingPoint(0)
    list_clip:SetDockOffset(0, 0)
    list_clip:Resize(remaining_width - 30, remaining_height - 30)

    local list_box = find_uicomponent(list_clip, "list_box")
    list_box:SetCanResizeWidth(true) list_box:SetCanResizeHeight(true)
    list_box:SetDockingPoint(1)
    list_box:SetDockOffset(0, 0)
    list_box:Resize(remaining_width - 30, remaining_height - 30)

    local l_handle = find_uicomponent(list_view, "vslider")
    l_handle:SetDockingPoint(6)
    l_handle:SetDockOffset(-20, 0)
end

function ui_obj:create_context_column()
    local panel = find_uicomponent(self.panel_name)
    local context_column = find_uicomponent(panel, "context_column")
    local img_path = effect.get_skinned_image_path("parchment_texture.png")

    local dummy = core:get_or_create_component("dummy", "ui/vandy_lib/custom_image_tiled", context_column)
    dummy:SetVisible(true)
    dummy:SetState('custom_state_2')
    dummy:SetImagePath(img_path, 1)
    dummy:SetCanResizeWidth(true) dummy:SetCanResizeHeight(true)
    dummy:Resize(context_column:Width(), context_column:Height())

    dummy:SetDockingPoint(5)
    dummy:SetDockOffset(0, 0)

    local h_diff = (dummy:Height() * 0.01) / 2

    local rites_holder = core:get_or_create_component("rites_holder", "ui/vandy_lib/script_dummy", dummy)
    rites_holder:Resize(dummy:Width(), dummy:Height() * 0.7)
    rites_holder:SetDockingPoint(2)
    rites_holder:SetDockOffset(0, (h_diff/2))

    local rites_title = core:get_or_create_component("rites_title", "ui/templates/panel_subtitle", rites_holder)
    rites_title:Resize(rites_holder:Width() * 0.95, rites_title:Height())
    rites_title:SetDockingPoint(2)
    rites_title:SetDockOffset(0, 10)

    local rites_title_text = core:get_or_create_component("text", "ui/vandy_lib/text/la_gioconda", rites_title)
    rites_title_text:SetVisible(true)
    rites_title_text:SetCanResizeWidth(true) rites_title_text:SetCanResizeHeight(true)
    rites_title_text:Resize(rites_title:Width() * 0.9, rites_title_text:Height() * 0.9)

    rites_title_text:SetDockingPoint(5)
    rites_title_text:SetDockOffset(0, 0)

    do
        local w,h = rites_title_text:TextDimensionsForText("Currently Selected Rite")
        rites_title_text:ResizeTextResizingComponentToInitialSize(w, h)
        rites_title_text:SetStateText("[[col:fe_white]]Currently Selected Rite[[/col]]")
    end

    local rites_flavour = core:get_or_create_component("rites_flavour", "ui/vandy_lib/text/la_gioconda", rites_holder)
    rites_flavour:SetVisible(true)

    rites_flavour:SetCanResizeWidth(true) rites_flavour:SetCanResizeHeight(true)
    rites_flavour:Resize(rites_flavour:Width() * 1.5, rites_flavour:Height() * 1.5)

    rites_flavour:SetDockingPoint(2)
    rites_flavour:SetDockOffset(0, rites_title:Height() + rites_flavour:Height() + 20)
    
    do
        local w,h = rites_flavour:TextDimensionsForText("Flavour text is located here, sir.")
        rites_flavour:ResizeTextResizingComponentToInitialSize(w, h)
        rites_flavour:SetStateText("Flavour text is located here, sir.")
    end

    local costs_holder = core:get_or_create_component("costs_holder", "ui/vandy_lib/script_dummy", dummy)
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
    end
end

function ui_obj:populate_panel_on_broodmother_selected(broodmother_obj)
    bmm:log("Populating on broodmother selected!")

    local panel = find_uicomponent(self.panel_name)
    local broodmother_column = find_uicomponent(panel, "broodmother_column")
    local traits_panel = find_uicomponent(broodmother_column, "dummy", "broodmother_details", "traits_panel")
    local list_box = find_uicomponent(traits_panel, "list_view", "list_clip", "list_box")

    -- clear any extant traits
    list_box:DestroyChildren()

    local template_path = "ui/broodmother/templates/"

    -- add in all the traits for this broodie
    local traits = broodmother_obj:get_traits()

    for i = 1, #traits do
        bmm:log("Creating trait img "..traits[i])
        local template = template_path .. traits[i]

        local dummy_uic = core:get_or_create_component(traits[i], "ui/vandy_lib/script_dummy", list_box)
        dummy_uic:SetVisible(true)
        dummy_uic:Resize(list_box:Width() * 0.9, list_box:Height() * 0.20)
        dummy_uic:SetDockingPoint(1)
        dummy_uic:SetDockOffset(0, 0)

        local new_uic = core:get_or_create_component(traits[i], template, dummy_uic)
        new_uic:SetVisible(true)
        new_uic:SetInteractive(true)
        new_uic:SetDockingPoint(4)
        new_uic:SetDockOffset(0, 0)

        local text = core:get_or_create_component("text", "ui/vandy_lib/text/la_gioconda", dummy_uic)
        text:SetVisible(true)
        text:SetDockingPoint(4)
        text:SetDockOffset(30, 0)
        text:SetStateText(effect.get_localised_string("effect_bundles_localised_title_"..traits[i]))
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

    local ok, err = pcall(function()
    self:create_actions_column()
    self:create_broodmother_column()
    self:create_context_column()
    end) if not ok then bmm:error(err) end
end


return ui_obj