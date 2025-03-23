extends Node

var player: CharacterBody3D = null
var grabpack: Node3D = null
var left_hand: Node3D = null
var right_hand: Node3D = null
var item_raycast: RayCast3D = null
var hud: CanvasLayer = null

func reset_objects():
	grabpack = get_tree().get_first_node_in_group("Grabpack")
	player = get_tree().get_first_node_in_group("Player")
	hud = get_tree().get_first_node_in_group("HUD")
	
	left_hand = get_tree().get_first_node_in_group("LeftHand")
	right_hand = get_tree().get_first_node_in_group("RightHand")
	
	item_raycast = get_tree().get_first_node_in_group("ItemRaycast")

#Movement Functions
func player_jump(height: float):
	player.external_jump(height)
func set_movable(value: bool):
	player.movable = value
func kill_player(_use_messages: bool = false):
	Game._load_no_screen("res://Interface/Death/death.tscn")

func lower_grabpack():
	grabpack.lower_grabpack()
	if not left_hand.hand_attached: left_hand.retract_hand()
	if not right_hand.hand_attached: right_hand.retract_hand()
func raise_grabpack():
	grabpack.raise_grabpack()
func toggle_grabpack():
	if grabpack.grabpack_lowered:
		grabpack.raise_grabpack()
	else:
		grabpack.lower_grabpack()
func switch_grabpack(grabpack_idx: int):
	grabpack.switch_grabpack(grabpack_idx)
func power_wire(power_material: StandardMaterial3D, power_specific_hand: bool = false, specific_hand: bool = true):
	var wireL = load("res://Player/Grabpack/Wire/WireMaterialLeft.tres")
	var wireR = load("res://Player/Grabpack/Wire/WireMaterialRight.tres")
	if not power_specific_hand:
		wireL.next_pass = power_material
		wireR.next_pass = power_material
		grabpack.wire_powered = true
	else:
		if specific_hand:
			wireR.next_pass = power_material
		else:
			wireL.next_pass = power_material
func dispower_wire(power_specific_hand: bool = false, specific_hand: bool = true):
	var wireL = load("res://Player/Grabpack/Wire/WireMaterialLeft.tres")
	var wireR = load("res://Player/Grabpack/Wire/WireMaterialRight.tres")
	if not power_specific_hand:
		wireL.next_pass = null
		wireR.next_pass = null
		grabpack.wire_powered = false
	else:
		if specific_hand:
			wireR.next_pass = null
		else:
			wireL.next_pass = null

#HAND POSITION FUNCTIONS
func left_position(new_position: Vector3):
	left_hand.hand_grab_point = new_position
	left_hand.hand_changed_point = true
func left_rotation(new_rotation: Vector3):
	left_hand.rotation = new_rotation
	left_hand.hand_changed_point = true
func left_specific_rotation_axis(axis: String, value: float):
	if axis == "x":
		left_hand.rotation.x = value
	elif axis == "y":
		left_hand.rotation.y = value
	elif axis == "z":
		left_hand.rotation.z = value
	left_hand.hand_changed_point = true
func left_transform(new_position: Vector3, new_rotation: Vector3):
	left_hand.hand_grab_point = new_position
	left_hand.rotation = new_rotation
	left_hand.hand_changed_point = true
func left_cancel_auto():
	left_hand.quick_retract = false
	left_hand.timer.stop()
func left_launch():
	left_hand.launch_hand()
func left_retract():
	left_hand.retract_hand()
func animate_left(anim_name: String):
	left_hand.play_animation(anim_name)
func left_seek(time: float):
	left_hand.animation_player.seek(time)

func right_position(new_position: Vector3):
	right_hand.hand_grab_point = new_position
	right_hand.hand_changed_point = true
func right_rotation(new_rotation: Vector3):
	right_hand.rotation = new_rotation
	right_hand.hand_changed_point = true
func right_specific_rotation_axis(axis: String, value: float):
	if axis == "x":
		right_hand.rotation.x = value
	elif axis == "y":
		right_hand.rotation.y = value
	elif axis == "z":
		right_hand.rotation.z = value
	right_hand.hand_changed_point = true
func right_transform(new_position: Vector3, new_rotation: Vector3):
	right_hand.hand_grab_point = new_position
	right_hand.rotation = new_rotation
	right_hand.hand_changed_point = true
func right_cancel_auto():
	right_hand.quick_retract = false
	right_hand.timer.stop()
func right_launch():
	right_hand.launch_hand()
func right_retract():
	right_hand.retract_hand()
func animate_right(anim_name: String):
	right_hand.play_animation(anim_name)
func right_seek(time: float):
	right_hand.seek_animation(time)

func add_hand(hand_scene: PackedScene, hand_idx: int = -1):
	var hand_instance = hand_scene.instantiate()
	if not hand_instance.has_node("Useless"):
		var inventory_icon: Texture2D = null
		var description = null
		if hand_instance.has_node("HandInventoryIcon"):
			var inventory_item_icon = hand_instance.get_node("HandInventoryIcon")
			inventory_icon = inventory_item_icon.icon
			if inventory_item_icon.has_description:
				description = inventory_item_icon.description
		
		var item_array: Array = [hand_instance.name, inventory_icon]
		if description:
			item_array.append(description)
		Inventory.items_Equipment.append(item_array)
	hand_instance.queue_free()
	if hand_idx < 0: right_hand.hands.append(hand_scene)
	else: right_hand.hands.insert(hand_idx, hand_scene)
	var index: int = hand_idx if hand_idx > -1 else 10
	right_hand.queue_hand_switch(index)
	print("yay")
func remove_hand(hand_name: String, replace_with_none: bool = true):
	var hand_idx: int = 0
	for i in right_hand.hands.size():
		var hand_instance = right_hand.hands[i].instantiate()
		if hand_instance.name == hand_name:
			hand_idx = i
		hand_instance.queue_free()
	if replace_with_none:
		right_hand.hands[hand_idx] = preload("res://Player/Grabpack/Hands/none.tscn")
	else:
		right_hand.hands.remove_at(hand_idx)
	Inventory.remove_item("items_Equipment", "RedHand")
	
	if right_hand.current_hand == hand_idx:
		if replace_with_none:
			right_hand.set_hand(hand_idx)
		else:
			right_hand.set_hand(hand_idx-1)
func get_hand():
	return Grabpack.right_hand.current_hand_node.name
