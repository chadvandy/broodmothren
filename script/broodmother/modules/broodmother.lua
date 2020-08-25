-- this is all the data held by a single "broodmother" object.

local broodmother_obj = {
    faction_key = "",
    location = "",

    traits = {},
}

function broodmother_obj.new(faction_key, region_key)
    local new_broodmother = {}

    setmetatable(new_broodmother, {__index = new_broodmother})

    new_broodmother.faction_key = faction_key
    new_broodmother.location = region_key

    return new_broodmother
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