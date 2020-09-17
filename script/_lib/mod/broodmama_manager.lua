-- only load this if it's campaign
if __game_mode ~= __lib_type_campaign then
    return
end

-- this is the initialization file that loads up the individual "modules" for UI and Broodmothas
-- warning: this script probably isn't very beginner-friendly to read. viewer discretion is advised.


local broodmama_manager = {
    __tostring = "BROODMANAGER",

    module_filepath = "script/broodmother/modules/",
    _logpath = "broodmother.txt",

    write_to_log = true,

    broodmothers = {},

    random_traits = {
        "example_1",
        "example_2",
        "example_3",
        "example_4",
        "broodmother_starved",
        "broodmother_gluttonous",
        "broodmother_vicious",
        "broodmother_lean",
        "broodmother_prolific",
        "broodmother_barren",
        "broodmother_nurturing",
        "broodmother_neglectful",
        "broodmother_paranoid",
        "broodmother_timid",
    },


    -- similar to CQI for TW objects; unique counter to identify broodmothers
    broodmother_unique_index = 1,

    slots = {
        [1] = "open",
        [2] = "open",
        [3] = "locked",
        [4] = "locked",
    }
}

function broodmama_manager:log_init()
    local file = io.open(self._logpath, "w+")
    file:write("NEW LOG INITIALIZED\n")
    local time_stamp = os.date("%d, %m %Y %X")
    file:write("[" .. time_stamp .. "]\n")
    file:close()
end

function broodmama_manager:log(text)
    if not is_string(text) and not is_number(text) then
        return false
    end

    if not self.write_to_log then
        return false
    end

    local file = io.open(self._logpath, "a+")
    file:write(text .. "\n")
    file:close()
end

function broodmama_manager:error(text)
    if not is_string(text) and not is_number(text) then
        return false
    end

    if not self.write_to_log then
        return false
    end

    local file = io.open(self._logpath, "a+")
    file:write("ERROR: " .. text .. "\n")
    file:write(debug.traceback("", 2) .. "\n")
    file:close()
end

function broodmama_manager:init()
    self:log_init()

    -- load individual modules
    self._UI_OBJ = self:load_module("ui", self.module_filepath)
    self._BROODMOTHER = self:load_module("broodmother", self.module_filepath)

    local data_path = self.module_filepath .. "data/"
    self._data = {}
    self._data.broodmothers = self:load_module("predefined_broodmothers", data_path)
    self._data.categories = self:load_module("categories", data_path)
    self._data.actions = self:load_module("actions", data_path)
end

function broodmama_manager:load_module(module_name, path)
    --[[if package.loaded[module_name] then
        return 
    end]]

    local full_file_name = path .. module_name .. ".lua"

    local file, load_error = loadfile(full_file_name)

    if not file then
        self:error("Attempted to load module with name ["..module_name.."], but loadfile had an error: ".. load_error .."")
        --return
    else
        self:log("Loading module with name [" .. module_name .. ".lua]")

        local global_env = core:get_env()
        local attach_env = {}
        setmetatable(attach_env, {__index = global_env})

        -- pass valuable stuff to the modules
        attach_env.broodmama_manager = self
        --attach_env.core = core

        setfenv(file, attach_env)
        local lua_module = file(module_name)
        package.loaded[module_name] = lua_module or true

        self:log("[" .. module_name .. ".lua] loaded successfully!")

        --if module_name == "mod_obj" then
        --    self.mod_obj = lua_module
        --end

        --self[module_name] = lua_module

        return lua_module
    end

    local ok, err = pcall(function() require(module_name) end)

    --if not ok then
        self:error("Tried to load module with name [" .. module_name .. ".lua], failed on runtime. Error below:")
        self:error(err)
        return false
    --end
end

-- return the unique counter and iterate it
function broodmama_manager:get_next_unique_counter()
    local current = self.broodmother_unique_index
    self.broodmother_unique_index = self.broodmother_unique_index + 1
    return current
end

function broodmama_manager:get_ui()
    return self._UI_OBJ
end

function broodmama_manager:get_broodmother_prototype()
    return self._BROODMOTHER
end

function broodmama_manager:get_predefined_broodmothers()
    return self._data.broodmothers
end

function broodmama_manager:get_predefined_broodmothers_for_faction(faction_key)
    if not is_string(faction_key) then
        -- errmsg
        return false
    end

    local test = self:get_predefined_broodmothers()[faction_key]
    if is_nil(test) then
        -- errmsg
        return false
    end

    return test
end

function broodmama_manager:add_predefined_broodmother_for_faction(faction_key, broodmother_name, broodmother_image_path, broodmother_traits)
    if not is_string(faction_key) then
        -- errmsg
        return false
    end

    if is_nil(broodmother_name) then
        broodmother_name = "Broodmother"
    end

    if not is_string(broodmother_name) then
        -- errmsg
        return false
    end

    if is_nil(broodmother_image_path) then
        broodmother_image_path = "ui/broodmother/Broodmama_generic_2_inactive.png"
    end

    if not is_string(broodmother_image_path) then
        -- errmsg
        return false
    end

    if is_nil(broodmother_traits) then
        broodmother_traits = {}
    end

    if not is_table(broodmother_traits) then
        -- errmsg
        return false
    end
end

function broodmama_manager:get_slot_state(index)
    if not is_number(index) then
        -- errmsg
        return false
    end

    if is_nil(self.slots[index]) then
        -- errmsg, slot doesn't exist
        return false
    end

    return self.slots[index]
end

function broodmama_manager:get_slots()
    return self.slots
end

function broodmama_manager:get_categories()
    return self._data.categories
end

function broodmama_manager:get_category_with_key(key)
    if not is_string(key) then
        -- errmsg
        return false
    end

    local test = self:get_categories()[key]
    if not test then
        -- errmsg
        return false
    end

    return test
end

function broodmama_manager:get_category_image(key)
    local cat = self:get_category_with_key(key)
    if not cat then
        -- errmsg
        return ""
    end

    return cat.img_path
end

function broodmama_manager:get_category_text(key)
    local cat = self:get_category_with_key(key)
    if not cat then
        -- errmsg
        return ""
    end

    return cat.text_string
end

function broodmama_manager:get_category_action_keys(key)
    local cat = self:get_category_with_key(key)
    if not cat then
        -- errmsg
        return {}
    end

    return cat.actions
end

function broodmama_manager:get_actions()
    local retval = {}
    for k, v in pairs(self._data.actions) do
        if k ~= "prototype" then
            retval[k] = v
        end
    end

    return retval
end

function broodmama_manager:get_action_prototype()
    return self._data.actions.prototype
end

function broodmama_manager:get_action_with_key(key)
    if not is_string(key) then
        -- errmsg
        return false
    end

    local test = self:get_actions()[key]
    if not test then
        -- errmsg
        return false
    end

    return test
end

function broodmama_manager:get_action_text_string(key)
    local dog = self:get_action_with_key(key)
    if not dog then
        -- errmsg
        return ""
    end

    return dog.text_string
end

function broodmama_manager:get_action_tooltip_string(key)
    local dog = self:get_action_with_key(key)
    if not dog then
        -- errmsg
        return ""
    end

    return dog.tooltip_string
end

function broodmama_manager:get_action_category_key(key)
    local dog = self:get_action_with_key(key)
    if not dog then
        -- errmsg
        return ""
    end

    return dog.category_key
end

function broodmama_manager:get_action_effect_bundle(key)
    local dog = self:get_action_with_key(key)
    if not dog then
        -- errmsg
        return ""
    end

    return dog.effect_bundle
end

function broodmama_manager:get_action_image_path(key)
    local dog = self:get_action_with_key(key)
    if not dog then
        -- errmsg
        return ""
    end

    return dog.img_path
end

function get_broodmother_manager()
    return core:get_static_object("broodmother_manager")
end

core:add_static_object("broodmother_manager", broodmama_manager, false)

_G.get_broodmother_manager = get_broodmother_manager

broodmama_manager:init()

function broodmama_manager:get_broodmothers()
    return self.broodmothers
end

function broodmama_manager:get_broodmother_with_key(key)
    if not is_string(key) then
        -- errmsg
        return false
    end

    local broodies = self.broodmothers
    for i = 1, #broodies do
        local brooder = broodies[i]
        if brooder:get_key() == key then
            return brooder
        end
    end 

    -- errmsg, none found
    return nil
end

function broodmama_manager:get_broodmother_with_index(index)
    if not is_number(index) then
        -- errmsg
        return false
    end

    local broodies = self:get_broodmothers()

    for i = 1, #broodies do
        local broooooooo = broodies[i]
        if broooooooo:get_index() == index then
            return broooooooo
        end
    end

    -- errmsg; none found
    return nil
end

function broodmama_manager:get_broodmothers_for_faction(faction_key)
    local blist = self.broodmothers

    local retval = {}

    self:log("Getting broodmothers for faction :"..faction_key)
    
    for i = 1, #blist do
        local broodmother_obj = blist[i]
        --self:log("S")
        if broodmother_obj:get_faction_key() == faction_key then
            retval[#retval+1] = broodmother_obj
        end
    end

    return retval
end

function broodmama_manager:get_random_traits()
    return self.random_traits
end

function broodmama_manager:get_random_traits_for_broodmother()
    local random_traits = self:get_random_traits()

    local copy = {}
    for i = 1, #random_traits do
        copy[#copy+1] = random_traits[i]
    end

    local num_traits = cm:random_number(3, 1)

    local retval = {}

    for i = 1, num_traits do
        local pos = cm:random_number(#copy, 1)
        local test_trait = copy[pos]

        -- TODO test validity?
        -- if is_valid() then
            retval[#retval+1] = test_trait
            -- remove the trait from copy
            table.remove(copy, pos)
        -- end

    end

    return retval
end

function broodmama_manager:create_new_broodmother(owning_faction, region_key)
    if not is_string(owning_faction) then
        -- errmsg
        return false
    end

    if not is_string(region_key) then
        -- errmsg
        return false
    end

    local new_broodmother = self:get_broodmother_prototype().new(owning_faction, region_key)

    self:log("New broodmother created for ["..owning_faction.."] at ["..region_key.."], index ["..tostring(new_broodmother:get_index()).."].")
    local random_traits = self:get_random_traits_for_broodmother()
    for i = 1, #random_traits do
        self:log("Adding trait to broodmother: "..random_traits[i])
        new_broodmother:add_trait(random_traits[i])
    end

    self.broodmothers[#self.broodmothers+1] = new_broodmother
end

function broodmama_manager:create_predefined_broodmother(obj)
    local faction_obj = cm:get_faction(obj.faction_key)
    if not faction_obj then
        -- issue
        return false
    end

    obj.location = faction_obj:home_region():name()

    local new_broodmother = self:get_broodmother_prototype().new_from_obj(obj)

    self:log("Predefined broodmother created for ["..new_broodmother:get_faction_key().."] with key ["..new_broodmother:get_key().."] in region ["..new_broodmother:get_location().."].")

    self.broodmothers[#self.broodmothers+1] = new_broodmother
end

-- this is called on the beginning of every new game.
-- create new broodmothers in all Skaven factions
-- do special stuff for player factions
function broodmama_manager:new_game_startup()
    local ok, err = pcall(function()
    local faction_list = cm:model():world():faction_list()

    local f = nil

    for i = 0, faction_list:num_items() -1 do
        local faction = faction_list:item_at(i)

        if faction:culture() == "wh2_main_skv_skaven" then
            f = faction
            break
        end
    end

    self:log("skaven faction found: "..f:name())
    local skv_faction_list = f:factions_of_same_culture()

    local function check_f(skv_faction)
        if skv_faction:is_quest_battle_faction() or skv_faction:is_dead() or skv_faction:is_rebel() then
            -- skip
        else
            -- create the new broodmother for this faction
            -- TODO what do if regionless?
            local location = ""
            if skv_faction:has_home_region() then
                location = skv_faction:home_region():name()
            end

            local faction_key = skv_faction:name()

            local test = self:get_predefined_broodmothers_for_faction(faction_key)

            if test then
                for j = 1, #test do
                    local broodmother_obj = test[j]
                    self:create_predefined_broodmother(broodmother_obj)
                end
            else
                self:create_new_broodmother(skv_faction:name(), location)
            end

            -- TODO remove testing
            if skv_faction:is_human() then
                -- do it two more times!
                self:create_new_broodmother(skv_faction:name(), location)
                -- actually just once more! self:create_new_broodmother(skv_faction:name(), location)
            end
        end
    end

    check_f(f)

    for i = 0, skv_faction_list:num_items() -1 do
        local skv_faction = skv_faction_list:item_at(i)

        check_f(skv_faction)
    end

end) if not ok then self:error(err) end
end

function broodmama_manager:instantiate_loaded_broodmothers(i,o)
    local prototype = self:get_broodmother_prototype()

    setmetatable(o, {__index = prototype})

    self.broodmothers[i] = o
end


-- save/load details!

cm:add_saving_game_callback(
    function(context)
        cm:save_named_value("broodmothers_list", broodmama_manager.broodmothers, context)
        cm:save_named_value("broodmothers_unique_counter", broodmama_manager.broodmother_unique_index, context)
        cm:save_named_value("broodmother_slots", broodmama_manager.slots, context)
    end
)

cm:add_loading_game_callback(
    function(context)
        if not cm:is_new_game() then
            broodmama_manager.broodmothers = cm:load_named_value("broodmothers_list", {}, context)
            broodmama_manager.broodmother_unique_index = cm:load_named_value("broodmothers_unique_counter", 0, context)
            broodmama_manager.slots = cm:load_named_value("broodmother_slots", {}, context)

            for i,o in pairs(broodmama_manager.broodmothers) do
                broodmama_manager:instantiate_loaded_broodmothers(i,o)
            end
        end
    end
)