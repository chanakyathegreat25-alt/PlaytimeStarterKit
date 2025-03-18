extends RigidBody3D

@onready var boom: AudioStreamPlayer3D = $Boom
@onready var animation_player: AnimationPlayer = $AnimationPlayer

signal exploded

var bombed: bool = false

func _on_flare_detector_flare_entered() -> void:
	boom.play()
	animation_player.play("explosion")
	exploded.emit()

func _on_animation_player_animation_finished(_anim_name: StringName) -> void:
	queue_free()
