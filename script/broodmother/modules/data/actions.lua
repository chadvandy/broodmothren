return {
    ["prototype"] = {
        tooltip_string = "broodmother_actions_prototype_tooltip",
        template_path = "ui/broodmother/templates/category_actions",
    },
    --[[["prototype"] = {
        text_string = "broodmother_actions_text",
        tooltip_string = 
    },]]
    enslave = {
        ["category_key"] = "careful_caretakers",
        ["text_string"] = "broodmother_actions_text_string_enslave",
        ["tooltip_string"] = "broodmother_actions_tooltip_string_enslave",
        ["img_path"] = "ui/broodmother/rhm2_care_enslave_icon.png",

        ["cost"] = {
            ["gold"] = 600,
            ["food"] = 0,
        },
        ["duration"] = 5,
        ["effect_bundle"] = "",
    },
    militarize = {
        ["category_key"] = "careful_caretakers",
        ["text_string"] = "broodmother_actions_text_string_militarize",
        ["tooltip_string"] = "broodmother_actions_tooltip_string_militarize",
        ["img_path"] = "ui/broodmother/rhm2_care_militarize_icon.png",

        ["cost"] = {
            ["gold"] = 20000,
            ["food"] = 0,
        },
        ["duration"] = 20,
        ["effect_bundle"] = "",
    },
    eat = {
        ["category_key"] = "careful_caretakers",
        ["text_string"] = "broodmother_actions_text_string_eat",
        ["tooltip_string"] = "broodmother_actions_tooltip_string_eat",
        ["img_path"] = "ui/broodmother/rhm2_care_eat_icon.png",

        ["cost"] = {
            ["gold"] = 20000,
            ["food"] = 0,
        },
        ["duration"] = 20,
        ["effect_bundle"] = "broodmother_eat",
    },
    quick = {
        ["category_key"] = "improved_incubators",
        ["text_string"] = "broodmother_actions_text_string_quick",
        ["tooltip_string"] = "broodmother_actions_tooltip_string_quick",
        ["img_path"] = "ui/broodmother/rhm2_infrastructure_quick_icon.png",

        ["cost"] = {
            ["gold"] = 20000,
            ["food"] = 0,
        },
        ["duration"] = 20,
        ["effect_bundle"] = "",
    },
    planning = {
        ["category_key"] = "improved_incubators",
        ["text_string"] = "broodmother_actions_text_string_planning",
        ["tooltip_string"] = "broodmother_actions_tooltip_string_planning",
        ["img_path"] = "ui/broodmother/rhm2_infrastructure_planning_icon.png",

        ["cost"] = {
            ["gold"] = 20000,
            ["food"] = 0,
        },
        ["duration"] = 20,
        ["effect_bundle"] = "",
    },
    engineer = {
        ["category_key"] = "improved_incubators",
        ["text_string"] = "broodmother_actions_text_string_engineer",
        ["tooltip_string"] = "broodmother_actions_tooltip_string_engineer",
        ["img_path"] = "ui/broodmother/rhm2_infrastructure_engineer_icon.png",

        ["cost"] = {
            ["gold"] = 250000000000,
            ["food"] = 0,
        },
        ["duration"] = 20,
        ["effect_bundle"] = "",
    },
    heal = {
        ["category_key"] = "clever_concoctions",
        ["text_string"] = "broodmother_actions_text_string_heal",
        ["tooltip_string"] = "broodmother_actions_tooltip_string_heal",
        ["img_path"] = "ui/broodmother/rhm2_research_heal_icon.png",

        ["cost"] = {
            ["gold"] = 5000,
            ["food"] = 0,
        },
        ["duration"] = 20,
        ["effect_bundle"] = "",
    },
    observe = {
        ["category_key"] = "clever_concoctions",
        ["text_string"] = "broodmother_actions_text_string_observe",
        ["tooltip_string"] = "broodmother_actions_tooltip_string_observe",
        ["img_path"] = "ui/broodmother/rhm2_research_observe_icon.png",

        ["cost"] = {
            ["gold"] = 0,
            ["food"] = 0,
        },
        ["duration"] = 20,
        ["effect_bundle"] = "",
    },
    experiment = {
        ["category_key"] = "clever_concoctions",
        ["text_string"] = "broodmother_actions_text_string_experiment",
        ["tooltip_string"] = "broodmother_actions_tooltip_string_experiment",
        ["img_path"] = "ui/broodmother/rhm2_research_experiment_icon.png",

        ["cost"] = {
            ["gold"] = 20000,
            ["food"] = 0,
        },
        ["duration"] = 20,
        ["effect_bundle"] = "",
    },
    feed = {
        ["category_key"] = "bigger_broodmothers",
        ["text_string"] = "broodmother_actions_text_string_feed",
        ["tooltip_string"] = "broodmother_actions_tooltip_string_feed",
        ["img_path"] = "ui/broodmother/rhm2_diet_feed_icon.png",

        ["cost"] = {
            ["gold"] = 0,
            ["food"] = 30,
        },
        ["duration"] = 20,
        ["effect_bundle"] = "",
    },
    starve = {
        ["category_key"] = "bigger_broodmothers",
        ["text_string"] = "broodmother_actions_text_string_starve",
        ["tooltip_string"] = "broodmother_actions_tooltip_string_starve",
        ["img_path"] = "ui/broodmother/rhm2_diet_starve_icon.png",

        ["cost"] = {
            ["gold"] = 1000,
            ["food"] = -50,
        },
        ["duration"] = 1,
        ["effect_bundle"] = "",
    },
    move = {
        ["category_key"] = "bigger_broodmothers",
        ["text_string"] = "broodmother_actions_text_string_move",
        ["tooltip_string"] = "broodmother_actions_tooltip_string_move",
        ["img_path"] = "ui/broodmother/rhm2_diet_move_icon.png",

        ["cost"] = {
            ["gold"] = 15,
            ["food"] = 0,
        },
        ["duration"] = 1,
        ["effect_bundle"] = "",
    },
}