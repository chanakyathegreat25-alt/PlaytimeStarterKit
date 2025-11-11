@tool
extends Node
class_name PuzzleLinker

@export var puzzle_list: Array[LinkedPuzzle]:
	set(value):
		if not Engine.is_editor_hint(): return
		puzzle_list = value
		if puzzle_list.size() > 0: puzzle_list[puzzle_list.size()-1].linker_node = self

var active: Array[bool]
var target_active: Array[bool]

signal all_active
signal another_active
signal deactivated
signal another_deactive

func _ready() -> void:
	if Engine.is_editor_hint(): return
	for i in puzzle_list.size():
		get_node(puzzle_list[i].puzzle).connect(puzzle_list[i].enable_signal, func(): puzzle_active(i))
		get_node(puzzle_list[i].puzzle).connect(puzzle_list[i].disable_signal, func(): puzzle_deactive(i))
		target_active.append(true)
func puzzle_active(idx):
	active[idx] = true
	if active == target_active:
		all_active.emit()
	else:
		another_active.emit()
func puzzle_deactive(idx):
	var deactivated_id: bool = false
	if active == target_active:
		deactivated_id = true
	active[idx] = false
	
	if deactivated_id: deactivated.emit()
	else: another_deactive.emit()
