extends StaticBody3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var open_sfx: AudioStreamPlayer3D = $OpenSFX
@onready var close_sfx: AudioStreamPlayer3D = $CloseSFX
@onready var unlock_sfx: AudioStreamPlayer3D = $UnlockSFX

@export var open: bool = false
@export var locked: bool = false
@export var unlockable_with_key: bool = false
@export var key_name: String = ""

signal opened
signal closed
signal locked_attempt

func _ready() -> void:
	if open:
		animation_player.play("open")
		animation_player.seek(0.9)

func toggle():
	if locked:
		if unlockable_with_key and Inventory.scan_list("items_Keys", key_name):
			locked = false
			unlock_sfx.play()
			opendoor()
			Inventory.remove_item("items_Keys", key_name)
			return
		animation_player.play("locked")
		emit_signal("locked_attempt")
		return
	if open:
		closedoor()
	else:
		opendoor()

func opendoor():
	if not open:
		animation_player.play("open")
		open = true
		opened.emit()
		open_sfx.play()
func closedoor():
	if open:
		animation_player.play("close")
		open = false
		closed.emit()
		close_sfx.play()

func _on_hand_grab_grabbed(_hand: bool) -> void:
	toggle()
func _on_basic_interaction_player_interacted() -> void:
	toggle()
