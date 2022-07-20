data:extend({
        {
            type = "string-setting",
            name = "qvs-swap-mode",
            order = "aa",
            setting_type = "runtime-per-user",
            default_value = "all",
            allowed_values = {
                "all",
                "top-1",
                "top-2",
                "top-3",
                "top-4",
            },
        },
        {
            type = "bool-setting",
            name = "qvs-blueprint-protection",
            order = "ab",
            setting_type = "runtime-per-user",
            default_value = true,
        },
        {
            type = "string-setting",
            name = "qvs-quickbar-blacklist",
            order = "ac",
            setting_type = "runtime-per-user",
            default_value = "",
            allow_blank = true,
        },
})
