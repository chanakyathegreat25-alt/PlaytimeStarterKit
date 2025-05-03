extends Node3D

@export var animation_player: AnimationPlayer = null
@export var idle_animation_name: String = ""
@export var idle_animation_speed: float = 1.0
@export var walk_animation_name: String = ""
@export var walk_animation_speed: float = 1.0
@export var run_animation_name: String = ""
@export var run_animation_speed: float = 1.5
@export var jumpscare_animation_name: String = ""
@export var jumpscare_animation_speed: float = 1.0

enum anims {
	idle,
	walk,
	run,
	jumpscare
}

func play_animation(anim_name: anims = anims.idle):
	if anim_name == anims.idle:
		animation_player.play(idle_animation_name)
		animation_player.speed_scale = idle_animation_speed
	elif anim_name == anims.walk:
		animation_player.play(walk_animation_name)
		animation_player.speed_scale = walk_animation_speed
	elif anim_name == anims.run:
		animation_player.play(run_animation_name)
		animation_player.speed_scale = run_animation_speed
	elif anim_name == anims.jumpscare:
		animation_player.play(jumpscare_animation_name)
		animation_player.speed_scale = jumpscare_animation_speed
