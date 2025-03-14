extends StaticBody3D

@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var basic_interaction: BasicInteraction = $BasicInteraction
@onready var card: Node3D = $Card
@onready var insert_sound: AudioStreamPlayer3D = $Inserted
@onready var beep: AudioStreamPlayer3D = $Beep
@onready var material: ORMMaterial3D = $Card/SM_KeyCard_B.get_surface_override_material(0)

@export var needed_keycard_name: String = ""
@export var needed_keycard_color: Color

var used: bool = false

signal inserted

func _ready() -> void:
	card.visible = false
	material.albedo_color = needed_keycard_color

func _on_basic_interaction_player_interacted() -> void:
	if Inventory.scan_list("items_Keys", needed_keycard_name) and not used:
		card.visible = true
		inserted.emit()
		animation_player.play("insert")
		Inventory.remove_item("items_Keys", "Keycard")
		basic_interaction.queue_free()
		insert_sound.play()
		
		used = true
		
		await animation_player.animation_finished
		beep.play()
