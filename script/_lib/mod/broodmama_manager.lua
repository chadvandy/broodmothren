-- this is the initialization file that loads up the individual "modules" for UI and Broodmothas
-- warning: this script probably isn't very beginner-friendly to read. viewer discretion is advised.


local broodmama_manager = {
    __tostring = "BROODMANAGER",

    module_filepath = "script/broodmother/modules/",
    _logpath = "broodmother.txt",

    broodmothers = {}
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
        attach_env.mct = self
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

function broodmama_manager:get_ui()
    return self._UI_OBJ
end

function broodmama_manager:get_broodmother_prototype()
    return self._BROODMOTHER
end

function get_broodmother_manager()
    return core:get_static_object("broodmother_manager")
end

core:add_static_object("broodmother_manager", broodmama_manager, false)

_G.get_broodmother_manager = get_broodmother_manager


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

    self:log("New broodmother created for ["..owning_faction.."] at ["..region_key.."].")

    self.broodmothers[#self.broodmothers+1] = new_broodmother
end


-- this is called on the beginning of every new game.
-- create new broodmothers in all Skaven factions
-- do special stuff for player factions
function broodmama_manager:new_game_startup()
    local faction_list = cm:model():world():faction_list()

    local f = nil

    for i = 0, faction_list:num_items() -1 do
        local faction = faction_list:item_at(i)

        if faction:culture() == "wh2_main_skv_skaven" then
            f = faction
            break
        end
    end

    local skv_faction_list = f:factions_of_same_culture()

    for i = 0, skv_faction_list:num_items() -1 do
        local skv_faction = skv_faction_list:item_at(i)

        -- create the new broodmother for this faction
        -- TODO what do if regionless?
        local location = ""
        if skv_faction:has_home_region() then
            location = skv_faction:home_region():name()
        end
        self:create_new_broodmother(skv_faction:name(), location)
    end
end