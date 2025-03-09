extends Node3D

@onready var inventory_item: InventoryItem = $InventoryItem
@onready var hand_grab: HandGrab = $HandGrab

func grabbed():
	hand_grab.release_grabbed()
	inventory_item.add_to_inventory()
	queue_free()

func _on_basic_interaction_player_interacted() -> void:
	grabbed()
func _on_hand_grab_let_go(hand: bool) -> void:
	grabbed()
