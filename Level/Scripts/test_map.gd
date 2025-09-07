extends Node3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer

func _ready() -> void:
	await animation_player.animation_finished
	Game.set_objective("Follow The Very Obvious Fucking Path")
