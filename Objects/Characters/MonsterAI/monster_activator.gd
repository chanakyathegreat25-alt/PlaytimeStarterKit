extends Node

enum states {
	disabled,
	roaming,
	path_follow,
	chase
}

@export var monster: CharacterBody3D = null
@export var state: states = states.roaming
@export var node: NodePath = ""
@export var node_signal: String = ""

func _ready() -> void:
	var activate_node = get_node(node)
	activate_node.connect(node_signal, Callable(activate))
func activate():
	monster.set_state(state)
