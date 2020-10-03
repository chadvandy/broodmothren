-- traits are defined here!

return {
    ["broodmother_vicious"] = {
        ["effect_bundle"] = {
            ["key"] = "broodmother_vicious",
            ["image_path"] = "ui/campaign ui/effect_bundles/public_order.png",
            ["effects"] = {
                {
                    ["key"] = "wh_main_effect_technology_research_points",
                    ["value"] = 5,
                    ["image_path"] = "ui/campaign ui/effect_bundles/magic.png",
                    ["effect_scope"] = "faction_to_faction_own",
                    ["is_good"] = true,
                },
            },
        },
        ["random"] = true,
    },
    ["broodmother_timid"] = {
        ["effect_bundle"] = {
            ["key"] = "broodmother_timid",
            ["image_path"] = "ui/campaign ui/effect_bundles/charge.png",
            ["effects"] = {
                {
                    ["key"] = "wh_main_effect_technology_research_points",
                    ["value"] = 10,
                    ["image_path"] = "ui/campaign ui/effect_bundles/magic.png",
                    ["effect_scope"] = "faction_to_faction_own",
                    ["is_good"] = true,
                },
            },
        },
        ["random"] = true,
    },
    ["broodmother_barren"] = {
        ["effect_bundle"] = {
            ["key"] = "broodmother_barren",
            ["image_path"] = "ui/campaign ui/effect_bundles/growth.png",
            ["effects"] = {
                {
                    ["key"] = "wh_main_effect_technology_research_points",
                    ["value"] = 20,
                    ["image_path"] = "ui/campaign ui/effect_bundles/magic.png",
                    ["effect_scope"] = "faction_to_faction_own",
                    ["is_good"] = true,
                },
            },
        },
        ["random"] = true,
    },
    ["broodmother_prolific"] = {
        ["effect_bundle"] = {
            ["key"] = "broodmother_prolific",
            ["image_path"] = "ui/campaign ui/effect_bundles/bestial_rage.png",
            ["effects"] = {
                {
                    ["key"] = "wh_main_effect_technology_research_points",
                    ["value"] = 300,
                    ["image_path"] = "ui/campaign ui/effect_bundles/magic.png",
                    ["effect_scope"] = "faction_to_faction_own",
                    ["is_good"] = true,
                },
            },
        },
        ["random"] = true,
    },
    ["broodmother_paranoid"] = {
        ["effect_bundle"] = {
            ["key"] = "broodmother_paranoid",
            ["image_path"] = "ui/campaign ui/effect_bundles/morale.png",
            ["effects"] = {
                {
                    ["key"] = "wh_main_effect_technology_research_points",
                    ["value"] = -10,
                    ["image_path"] = "ui/campaign ui/effect_bundles/magic.png",
                    ["effect_scope"] = "faction_to_faction_own",
                    ["is_good"] = false,
                },
            },
        },
        ["random"] = true,
    },
    ["broodmother_nurturing"] = {
        ["effect_bundle"] = {
            ["key"] = "broodmother_nurturing",
            ["image_path"] = "ui/campaign ui/effect_bundles/turns.png",
            ["effects"] = {
                {
                    ["key"] = "wh_main_effect_technology_research_points",
                    ["value"] = 60000,
                    ["image_path"] = "ui/campaign ui/effect_bundles/magic.png",
                    ["effect_scope"] = "faction_to_faction_own",
                    ["is_good"] = true,
                },
            },
        },
        ["random"] = true,
    },
}