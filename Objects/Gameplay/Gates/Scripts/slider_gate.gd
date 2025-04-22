extends StaticBody3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var open_sfx: AudioStreamPlayer3D = $OpenSFX
@onready var close_sfx: AudioStreamPlayer3D = $CloseSFX

@export var open: bool = false

signal openned
signal closed

func _ready() -> void:
	if open:
		animation_player.play("open")
		animation_player.seek(1.4)

func opengate():
	if not open:
		animation_player.play("open")
		open = true
		open_sfx.play()
		await animation_player.animation_finished
		openned.emit()
func closegate():
	if open:
		animation_player.play("close")
		open = false
		close_sfx.play()
		await animation_player.animation_finished
		closed.emit()

func toggle():
	if open:
		closegate()
	else:
		opengate()
