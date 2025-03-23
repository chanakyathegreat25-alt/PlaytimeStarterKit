extends Node

var hud = null
var checkpoint: int = 0

var current_objective = "none"
var saves: Array = []

func reset_nodes():
	if not get_tree().get_first_node_in_group("HUD") == null:
		hud = get_tree().get_first_node_in_group("HUD")

func set_objective(objective: String):
	hud.new_objective(objective)
	current_objective = objective
func tutorial(tutorial_text: String):
	hud.tutorial_notify(tutorial_text)
func tooltip(tooltip_text: String):
	hud.tooltip(tooltip_text)

#LOAD SYSTEM:

var _load_screen_path : String = "res://Interface/Loading/loading_screen.tscn"
var load_screen = load(_load_screen_path)
var previous_level: String

func load_scene(scene_path):
	previous_level = get_tree().current_scene.get_path()
	var new_loading_screen = load_screen.instantiate()
	get_tree().get_root().add_child(new_loading_screen)
	new_loading_screen.scene_path = scene_path
	new_loading_screen.start()

func _load_no_screen(Scene : NodePath):
	previous_level = get_tree().current_scene.scene_file_path
	get_tree().change_scene_to_file(Scene)

func save_game(new_checkpoint, save_title: String = "Untitled Save", save_image: Texture2D = preload("res://Interface/Inventory/ItemIcons/T_GreenHand_Inventory.png")):
	if new_checkpoint <= checkpoint: return
	if hud: hud.save()
	checkpoint = new_checkpoint
	saves.append([save_title, current_objective, save_image, new_checkpoint])
func reset_checkpoint():
	checkpoint = 0

func load_checkpoint():
	#ADD YOUR LOAD CHECKPOINT CODE HERE
	pass

#CUSTOM DATA:

var omni_charges: int = 4
