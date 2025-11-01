extends Node

@onready var settings_menu = $"../../.."

func reset_to_defualts():
	GameSettings.setting_values = GameSettings.default_values
	
	#RESET OTHER
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	get_viewport().scaling_3d_scale = GameSettings.get_setting("anti_aliasing")
	Game.load_quality_environments()
	var viewport: Viewport = get_viewport()
	if GameSettings.get_setting("anti_aliasing") == 0: viewport.msaa_3d = Viewport.MSAA_DISABLED
	elif GameSettings.get_setting("anti_aliasing") == 1: viewport.msaa_3d = Viewport.MSAA_2X
	elif GameSettings.get_setting("anti_aliasing") == 2: viewport.msaa_3d = Viewport.MSAA_4X
	elif GameSettings.get_setting("anti_aliasing") == 2: viewport.msaa_3d = Viewport.MSAA_8X
	AudioServer.set_bus_volume_db(0, linear_to_db(GameSettings.get_setting("master_volume")/100))
	AudioServer.set_bus_volume_db(0, linear_to_db(GameSettings.get_setting("music_volume")/100))

func _unhandled_input(_event):
	if settings_menu.visible and Input.is_action_just_pressed("reset"):
		var result = await settings_menu.get_node(settings_menu.menu_popup).prompt("Reset To Defualts", "This will reset all settings to their defualt value.")
		if result:
			reset_to_defualts()

#func _on_settings_box_5_toggled(toggled_on: bool) -> void:
	#GameSettings.mobile_controls = toggled_on
	#if Grabpack.player != null:
		#if toggled_on:
			#if Grabpack.player.has_node("MobileControls"): return
			#var mobile = load("res://Interface/Mobile/mobile_controls.tscn").instantiate()
			#mobile.name = "MobileControls"
			#Grabpack.player.add_child(mobile)
		#else:
			#if Grabpack.player.has_node("MobileControls"):
				#Grabpack.player.get_node("MobileControls").queue_free()

func apply():
	var viewport: Viewport = get_viewport()
	viewport.scaling_3d_scale = GameSettings.get_setting("resolution_scale")
	if GameSettings.get_setting("anti_aliasing") == 0: get_viewport().msaa_3d = Viewport.MSAA_DISABLED
	elif GameSettings.get_setting("anti_aliasing") == 1: get_viewport().msaa_3d = Viewport.MSAA_2X
	elif GameSettings.get_setting("anti_aliasing") == 2: get_viewport().msaa_3d = Viewport.MSAA_4X
	elif GameSettings.get_setting("anti_aliasing") == 2: get_viewport().msaa_3d = Viewport.MSAA_8X
	Game.load_quality_environments()
