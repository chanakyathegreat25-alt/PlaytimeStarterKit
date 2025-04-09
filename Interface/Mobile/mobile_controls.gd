extends Control

@onready var drag: Control = $Drag

func _process(_delta: float) -> void:
	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED: Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	Input.action_press("sprint")
