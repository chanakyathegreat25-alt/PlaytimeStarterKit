extends Area3D
##Detects when a flare enters the area.
class_name FlareDetector

signal flare_entered
@export var usable_once: bool = true

var used: bool = false

func _ready() -> void:
	connect("area_entered", Callable(area_detected))

func area_detected(area):
	if area.is_in_group("FlareBall") and not used:
		flare_entered.emit()
		if usable_once:
			used = true
