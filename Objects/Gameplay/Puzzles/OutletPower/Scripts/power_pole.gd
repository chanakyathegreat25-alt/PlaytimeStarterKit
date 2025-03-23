extends StaticBody3D

@onready var light = $Light
@onready var grabbed = $Grabbed
@onready var released = $Released

var is_powered: bool = false
var areas: int = 0

func _ready():
	light.visible = false

func _process(delta: float) -> void:
	if not Grabpack.grabpack.wire_powered and is_powered:
		set_power(false)

func set_power(value):
	is_powered = value
	light.visible = value
	if value:
		grabbed.play()
	else:
		released.play()

func _on_wire_detection_area_entered(area):
	if area.is_in_group("WireSegment"):
		areas += 1
		if areas > 0 and Grabpack.grabpack.wire_powered and not is_powered:
			set_power(true)

func _on_wire_detection_area_exited(area):
	if area.is_in_group("WireSegment"):
		areas -= 1
		if areas < 1 and is_powered:
			set_power(false)
