extends Control

@export var menu_popup: NodePath

@onready var tabs = $section/Tabs
@onready var setting_title = $section/setting_title
@onready var setting_description = $section/setting_description
@onready var title = $section/Title/title
@onready var load_animation = $section/LoadAnimation
@onready var tab_indecator = $Tabs/TabIndecator

var tabs_names = ["CONTROLS", "DISPLAY", "GRAPHICS", "AUDIO", "LANGUAGE"]
var current_tab: Node2D = null
var previous_tab_button: Button = null

func _ready():
	load_tab("Tab1",get_node("Tabs/1"))
	visible = false
	await Game.delay(0.5)
	toggle()

func toggle():
	if visible:
		$section/Tabs/SettingsManager.apply()
	else:
		pass
	visible = !visible

func _unhandled_input(_event):
	if visible:
		if Input.is_action_just_pressed("exit"):
			toggle()
		if Input.is_action_just_pressed("rotate_left"):
			var switching_to: int = int(previous_tab_button.name)-1
			if switching_to < 1: switching_to = 5
			load_tab(str("Tab",switching_to), $Tabs.get_node(str(switching_to)))
			$Tabs/ButtonSFXPlayer/Forward.play()
		if Input.is_action_just_pressed("rotate_right"):
			var switching_to: int = int(previous_tab_button.name)+1
			if switching_to > 5: switching_to = 1
			load_tab(str("Tab",switching_to), $Tabs.get_node(str(switching_to)))
			$Tabs/ButtonSFXPlayer/Forward.play()

func load_tab(tab: String, node: Button):
	if current_tab: 
		current_tab.visible = false
		current_tab = null
	var next_tab = tabs.get_node(tab)
	next_tab.visible = true
	title.text = tabs_names[int(tab)-1]
	load_animation.play("loaded")
	current_tab = next_tab
	tab_indecator.position.x = node.position.x
	if previous_tab_button:
		previous_tab_button.modulate = "767f87"
		previous_tab_button.remove_theme_stylebox_override("normal")
	previous_tab_button = node
	node.modulate = "ffffffff"
func setting_pressed(titleset, descriptionset, y_pos):
	setting_title.text = titleset
	setting_description.text = descriptionset
func setting_exited():
	return

func _on_back_pressed():
	if visible:
		toggle()


func _on_label_visibility_changed() -> void:
	pass # Replace with function body.
