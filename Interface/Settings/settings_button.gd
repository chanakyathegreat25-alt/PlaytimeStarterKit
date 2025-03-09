extends Button

@export var setting_name: String = ""
@export var setting_description:  String = ""
@export var settings_root: NodePath
@export var is_slider: bool = false
@export var slider_use_percentage: bool = false

var setting_node: Control = null

func _ready():
	connect("mouse_entered", Callable(send_data))
	setting_node = get_node(settings_root)
	connect("mouse_exited", Callable(setting_node.setting_exited))
	if has_node("HSlider"):
		var slider: HSlider = get_node("HSlider")
		slider.connect("value_changed", Callable(update_slider))

func send_data():
	setting_node.setting_pressed(setting_name, setting_description, position.y)

func update_slider(value: int):
	if slider_use_percentage:
		$Label.text = str(value, "%")
	else:
		$Label.text = str(value)
