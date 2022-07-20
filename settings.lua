data:extend({
        {
            type = "string-setting",
            name = "qvs-swap-mode",
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
            type = "string-setting",
            name = "qvs-quickbar-blacklist",
            setting_type = "runtime-per-user",
            default_value = "",
            allow_blank = true,
        },
})
