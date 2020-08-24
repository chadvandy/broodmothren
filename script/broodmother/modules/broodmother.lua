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
end



return broodmother_obj