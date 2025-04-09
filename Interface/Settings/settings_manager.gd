extends Node

@onready var settings_menu = $"../../.."

#TAB1
@onready var camera_sense = $"../Tab1/SettingsBox/HSlider"
@onready var toggle_sprint = $"../Tab1/SettingsBox2"
@onready var toggle_crouch = $"../Tab1/SettingsBox3"
@onready var keybinds = $"../Tab1/SettingsBox4"
@onready var mobile_controls: CheckButton = $"../Tab1/SettingsBox5"

#TAB2
@onready var window_mode = $"../Tab2/SettingsBox"
@onready var vsync = $"../Tab2/SettingsBox2"
@onready var show_fps = $"../Tab2/SettingsBox3"
@onready var fov = $"../Tab2/SettingsBox4/HSlider"

#TAB3

#TAB4
@onready var main_volume = $"../Tab4/SettingsBox/HSlider"
@onready var music_volume = $"../Tab4/SettingsBox2/HSlider"

func _ready():
	update_all_visual()
func update_all_visual():
	camera_sense.value = GameSettings.fov
	toggle_sprint.button_pressed = GameSettings.toggle_sprint
	toggle_crouch.button_pressed = GameSettings.toggle_crouch
	mobile_controls.button_pressed = GameSettings.mobile_controls
	window_mode.selected = GameSettings.window_mode
	vsync.button_pressed = GameSettings.vsync
	show_fps.button_pressed = GameSettings.show_fps
	fov.value = GameSettings.fov
	main_volume.value = GameSettings.main_volume
	music_volume.value = GameSettings.music_volume
func reset_to_defualts():
	GameSettings.camera_sens = 50
	GameSettings.toggle_sprint = false
	GameSettings.toggle_crouch = false
	GameSettings.window_mode = 0
	GameSettings.vsync = false
	GameSettings.show_fps = false
	GameSettings.fov = 75
	GameSettings.main_volume = 100
	GameSettings.music_volume = 100
	GameSettings.mobile_controls = false
	
	#RESET OTHER
	DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	AudioServer.set_bus_volume_db(0, linear_to_db(GameSettings.main_volume/100))
	AudioServer.set_bus_volume_db(0, linear_to_db(GameSettings.music_volume/100))
	
	update_all_visual()

func _unhandled_input(_event):
	if settings_menu.visible and Input.is_action_just_pressed("reset"):
		var result = await settings_menu.get_node(settings_menu.menu_popup).prompt("Reset To Defualts", "This will reset all settings to their defualt value.")
		if result:
			reset_to_defualts()

#TAB1
func cam_sense_changed(value):
	GameSettings.camera_sens = value
func toggle_sprint_changed(toggled_on):
	GameSettings.toggle_sprint = toggled_on
func toggle_crouch_changed(toggled_on):
	GameSettings.toggle_crouch = toggled_on
func _on_settings_box_5_toggled(toggled_on: bool) -> void:
	GameSettings.mobile_controls = toggled_on
	if Grabpack.player != null:
		if toggled_on:
			if Grabpack.player.has_node("MobileControls"): return
			var mobile = load("res://Interface/Mobile/mobile_controls.tscn").instantiate()
			mobile.name = "MobileControls"
			Grabpack.player.add_child(mobile)
		else:
			if Grabpack.player.has_node("MobileControls"):
				Grabpack.player.get_node("MobileControls").queue_free()

#TAB2
func window_mode_changed(index):
	if index == 0:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	elif index == 1:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_EXCLUSIVE_FULLSCREEN)
	elif index == 2:
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)
	GameSettings.window_mode = index
func vsync_toggled(toggled_on):
	if toggled_on:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
	GameSettings.vsync = toggled_on
func show_fps_toggled(toggled_on):
	GameSettings.show_fps = toggled_on
func fov_changed(value):
	GameSettings.fov = value

#TAB3

#TAB4
func main_volume_changed(value):
	GameSettings.main_volume = value
	AudioServer.set_bus_volume_db(0, linear_to_db(value/100))
func music_volume_changed(value):
	GameSettings.music_volume = value
	AudioServer.set_bus_volume_db(1, linear_to_db(value/100))

#TAB5
func game_language_changed(_index):
	pass # Replace with function body.
