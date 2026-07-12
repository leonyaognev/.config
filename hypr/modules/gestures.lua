----- ЖЕСТЫ --------------------------------------------------------------------
hl.config({
	gestures = {
		workspace_swipe_distance = 1000,
		workspace_swipe_forever = true,
	},
})

hl.gesture({
	fingers = 3,
	direction = "horizontal",
	action = "workspace",
})
