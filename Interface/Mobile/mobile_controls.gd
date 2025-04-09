extends Control

@onready var drag: Control = $Drag
@onready var gp_extra: Node2D = $GP_Extra
@onready var watch: TouchScreenButton = $GP_Extra/Watch

func _process(_delta: float) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED: Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Input.action_press("sprint")
	if Grabpack.grabpack.current_grabpack > 1:
		gp_extra.visible = true
		if Grabpack.grabpack.current_grabpack == 3:
			watch.visible = true
		else:
			watch.visible = false
	else:
		gp_extra.visible = false
