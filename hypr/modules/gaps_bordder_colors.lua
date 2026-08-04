----- ГАПСЫ, БОРДЕРЫ, ЦВЕТА... -------------------------------------------------
local colors = require("modules.colors")

hl.config({
	general = {
		gaps_in = 3,
		gaps_out = 6,
		border_size = 2,
		col = {
			active_border = colors.active_border,
			inactive_border = colors.inactive_border,
		},
		layout = "master",
	},
	decoration = {
		blur = {
			enabled = true,
			size = 5,
			passes = 2,
			vibrancy = 0.4,
			ignore_opacity = true,
		},
		rounding = 20,
		shadow = {
			enabled = true,
			range = 5,
			render_power = 3,
			color = "rgba(0,0,0,0.2)",
		},
		active_opacity = 1.0,
		inactive_opacity = 0.9,
	},
})

----- НАСТРОЙКА ЛАЙОУТОВ -------------------------------------------------------
hl.config({
	dwindle = {
		preserve_split = true,
	},
})
