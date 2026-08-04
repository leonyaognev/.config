----- АВТОСТАРТ ДЕМОНОВ --------------------------------------------------------
----- АВТОСТАРТ ПРИЛОЖЕНИЙ -----------------------------------------------------

hl.on("hyprland.start", function()
	hl.exec_cmd("awww-daemon")
	hl.exec_cmd("quickshell")
	hl.exec_cmd("swaync")
	hl.exec_cmd("waybar -c ~/.config/waybar/config -s ~/.config/waybar/style.css")
	hl.exec_cmd("wl-clip-persist --clipboard regular --display wayland-1")
	hl.exec_cmd("zen-browser", { workspace = "1" })
	hl.exec_cmd("kitty", { workspace = "2" })
end)

hl.config({
	misc = {
		vrr = false,
		disable_splash_rendering = false,
	},
})
