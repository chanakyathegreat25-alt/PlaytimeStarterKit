extends Area3D

var hand_node
var origin_node
var next_node

var wrap_object = null
var wrap_offset: Vector3 = Vector3.ZERO
var active: bool = false
var check_distance: float = 0.3
var point: Vector3 = Vector3.ZERO
var angle: float = 0.0
var hand: bool = false
@onready var ray_cast_3d = $RayCast3D
@onready var timer = $Timer

func _process(_delta):
	update_wire()
	if not active: return
	if hand_node.wire_wrap: handle_wrap()
	if hand_node.wire_unwrap: handle_unwrap()
	if Input.is_action_just_pressed("toggle_grabpack"):
		set_angle()

func handle_unwrap():
	
	if not origin_node or not next_node: return
	if not origin_node is Area3D: return
	if not origin_node.point == Vector3.ZERO: return
	if angle == 0.0: return
	var new_angle: Vector2 = get_angle()
	if new_angle.x > new_angle.y if angle > 0.0 else new_angle.x < new_angle.y:
		origin_node.active = false
		origin_node.timer.start(0.1)
		get_parent().remove_segment(self, origin_node, next_node)
func get_angle():
	if not origin_node or not next_node: return Vector2(0.0, 0.0)
	var player_point = origin_node.global_position
	var corner_point = global_position
	var hand_point = next_node.global_position
	
	var player_vec:Vector2 = Vector2(player_point.x, player_point.z)
	var corner_vec:Vector2 = Vector2(corner_point.x, corner_point.z)
	var hand_vec:Vector2 = Vector2(hand_point.x, hand_point.z)
	
	#PLAYER, CORNER
	var angle1 = (player_vec - corner_vec).angle()
	
	#CORNER, HAND
	var angle2 = (corner_vec - hand_vec).angle()
	return Vector2(angle1, angle2)
func set_angle():
	var new_angle: Vector2 = get_angle()
	if new_angle.x > new_angle.y: angle = -1.0
	else: angle = 1.0
func handle_wrap():
	if not origin_node or not next_node: return
	if ray_cast_3d.is_colliding():
		if ray_cast_3d.get_collider() is CharacterBody3D: return
		var collide_point: Vector3 = ray_cast_3d.get_collision_point()
		if collide_point.distance_to(next_node.global_position) < check_distance or collide_point.distance_to(global_position) < check_distance: return
		next_node = get_parent().add_segment(self, next_node, collide_point)
		var object = ray_cast_3d.get_collider()
		if object == null:
			object = origin_node
		next_node.wrap_object = object
		next_node.wrap_offset = next_node.wrap_object.global_position - collide_point
		
		active = false
		timer.start(0.1)

func update_wire():
	if wrap_object:
		point = wrap_object.global_position - wrap_offset
	if point != Vector3.ZERO:
		global_position = point
	elif origin_node:
		global_transform.origin = origin_node.global_transform.origin
	if next_node:
		look_at(next_node.global_transform.origin)
		scale.z = global_transform.origin.distance_to(next_node.global_transform.origin)

func _on_timer_timeout():
	active = true
	visible = true
	set_angle()
