local bmm = broodmama_manager

-- this is all the data held by a single "broodmother" object.

local broodmother_obj = {
    --faction_key = "",
    --location = "",

    --traits = {},
}

function broodmother_obj.new_from_obj(o)
    o = o or {}

    setmetatable(o, {__index = broodmother_obj})

    o.index = bmm:get_next_unique_counter()

    -- TODO catch if they're regionless!
    o.location = cm:get_faction(o.faction_key):home_region():name()

    o.resources = {
        docile = 0,
        starvation = 0,
    }

    o.active_effect = nil

    return o
end

function broodmother_obj.new(faction_key, region_key, base_image)
    local new_broodmother = {}

    setmetatable(new_broodmother, {__index = broodmother_obj})

    new_broodmother.faction_key = faction_key
    new_broodmother.location = region_key
    new_broodmother.traits = {}
    new_broodmother.name = "Broodmother"
    new_broodmother.active_effect = nil

    new_broodmother.resources = {
        docile = 0,
        starvation = 0,
    }

    new_broodmother.index = bmm:get_next_unique_counter()

    if not base_image then
        new_broodmother:assign_random_image()
    else
        new_broodmother.image = base_image
    end

    return new_broodmother
end

function broodmother_obj:get_active_effect()
    return self.active_effect
end

function broodmother_obj:set_active_effect(key)
    if key and not is_string(key) then
        -- errmsg
        return false
    end

    self.active_effect = key
end

function broodmother_obj:perform_effect(selected_action_key)
    if not selected_action_key then
        -- errmsg!
        return false
    end

    local action_data = bmm._data.actions[selected_action_key]
    if not action_data then
        -- errmsg?
        return false
    end

    local eb = action_data.effect_bundle

    if not is_table(eb) then
        -- errmsg
        return false
    end

    self:set_active_effect(selected_action_key)

    local eb_key = eb.key
    local duration = action_data.duration

    local effects = eb.effects

    local custom_effect_bundle = cm:create_new_custom_effect_bundle(eb_key)
    custom_effect_bundle:set_duration(duration)

    for i = 1, #effects do
        local fx = effects[i]
        local key = fx.key
        local scope = fx.effect_scope
        local val = fx.value

        custom_effect_bundle:add_effect(key, scope, val)
    end

    local region_key = self:get_location()
    local region_obj = cm:get_region(region_key)

    -- apply the EB to the region where the BM is located
    cm:apply_custom_effect_bundle_to_region(custom_effect_bundle, region_obj)

    -- TODO apply the costs
    local cost = action_data.cost
    local gold_cost = cost.gold
    local food_cost = cost.food

    local faction_key = self:get_faction_key()

    -- remove the gold
    if is_number(gold_cost) and gold_cost ~= 0 then
        cm:treasury_mod(faction_key, -gold_cost)
    end

    if is_number(food_cost) and food_cost ~= 0 then
        cm:faction_add_pooled_resource(faction_key, "skaven_food", "canibalism", -food_cost)
    end
end

function broodmother_obj:assign_random_image()
    -- TODO test for eshin/etc
    local index = cm:random_number(4, 1)

    self.image = "ui/broodmother/Broodmama_generic_"..tostring(index).."_inactive.png"
end

function broodmother_obj:get_base_image()
    return self.image
end

function broodmother_obj:get_name()
    return self.name
end

function broodmother_obj:set_name(text)
    if not is_string(text) then
        -- errmsg
        return false
    end

    self.name = text
end

function broodmother_obj:get_index()
    return self.index
end

function broodmother_obj:get_key()
    return "broodmother_"..tostring(self:get_index())
end

function broodmother_obj:add_trait(trait_key)
    if not is_string(trait_key) then
        bmm:error("add_trait called on a broodmother, but the trait key wasn't a string!")
        return false
    end

    -- TODO check if there's max traits?
    -- TODO check if there's a conflicting trait?
    self.traits[#self.traits+1] = trait_key
end

function broodmother_obj:get_traits()
    return self.traits
end

function broodmother_obj:change_location(new_region_key)
    if not is_string(new_region_key) then
        -- errmsg
        return false
    end

    self.location = new_region_key
end

function broodmother_obj:get_location()
    return self.location
end

function broodmother_obj:get_faction_key()
    return self.faction_key
end

function broodmother_obj:set_resource_num_with_key(resource_key, num)
    if not is_string(resource_key) then
        -- errmsg
        return false
    end

    if not self.resources[resource_key] then
        -- errmsg, invalid key
        return false
    end

    if not is_number(num) then
        -- errmsg
        return false
    end

    -- TODO catch if it's too high or too low

    self.resources[resource_key] = num
end

function broodmother_obj:change_resource_num_by_amount(resource_key, change_amount)
    if not is_string(resource_key) then
        -- errmsg
        return false
    end

    if not self.resources[resource_key] then
        -- errmsg, invalid key
        return false
    end

    if not is_number(change_amount) then
        -- errmsg
        return false
    end

    -- TODO catch if it's too high or too low
    self.resources[resource_key] = self.resources[resource_key] + change_amount
end

function broodmother_obj:get_resource_num_with_key(resource_key)
    if not is_string(resource_key) then
        -- errmsg
        return false
    end

    if not self.resources[resource_key] then
        -- invalid key, errmsg
        return false
    end

    return self.resources[resource_key]
end

return broodmother_obj


--[[
    trait ideas (try for ~12 total?):

    Starved
    Gluttonous
    Vicious
    Lean
    Prolific
    Barren
    Nurturing
    Neglectful
    Paranoid
    Timid
]]

--[[
    unique clan trait ideas:

    Pestilens
        Festering
        Fanatical

    Eshin
        Stealthy
        Suspicious

    Skryre
        Inventive
        Insane

    Moulder
        Grotesque
        Gibbering

]]

--[[
    per-category rite ideas:

    Nutrition:
        - Feed: A rite that removes a flat number of food, but grants a factionwide boost of growth for x turns, and reduces recruitment time and increases recruitment rank in local province. Too much feeding and the broodie will increase in size, eventually becoming impossible to move.
        - Starve: A rite that shrinks the Broodmother and removes the increased food cost for a larger size, but comes at the cost of growth loss and potentially hurting the broodie.

    Caregivers:
        - Militarize: create regular units, minor chance for elites like rat ogres, stormvermin, basic chance for clanrats. Increase to recruitment rank locally
        - Weaponize: 
        - Indoctrinate: 
        - Unionize

    Personnel:
        - Submit: tighten leash - Broodmother loses control
        - Lighten: loosen the leash around the throat - Broodmother gains slightly more control over surroundings, their children, etc.
        - Care: heal any damage to prevent certain death
        - Transport: move to another facility

    Misc. (maybe swap Experiment for per-faction unique thing? "fester" for Pestilens, etc):
        - Experiment: test unique concoctions on the Broodmother and the next spawn. Can potentially have some positive effects - though weird (potentially spawn HPA for instance) - or some disastrous effects.
        - Feast: kill the Broodmother and have a feast like never seen before
        - 
        -

]]