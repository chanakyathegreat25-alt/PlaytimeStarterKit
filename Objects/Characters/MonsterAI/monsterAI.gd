extends CharacterBody3D

@onready var idle_timer: Timer = $IdleTimer
@onready var nav_agent: NavigationAgent3D = $NavigationAgent3D
@onready var raycast: RayCast3D = $RayCast
var prev_look: Vector3 = transform.origin
var LERP_SPEED: float = 5.0

enum states {
	disabled,
	roaming,
	path_follow,
	chase
}

enum actions {
	idle,
	walk,
	run,
	jumpscare
}

@export var monster_visual: Node3D = null
@export_category("State Settings")
@export var default_state: states = states.disabled
@export_subgroup("Roaming")
@export var roaming_ai_marks: Node = null
@export var use_sound_tracking: bool = true
@export var crouch_footstep_distance: float = 2.0
@export var walk_footstep_distance: float = 5.0
@export var run_footstep_distance: float = 15.0
@export var grabpack_use_distance: float = 25.0
@export var use_visual_tracking: bool = true
@export var sight_distance: float = 30.0
@export_category("Movement")
@export var walk_speed: float = 3.0
@export var run_speed: float = 6.0
@export var idle_time: Vector2 = Vector2(2.0, 4.0)

var current_state: states = states.disabled
var current_action: actions = actions.walk

#ROAMING VARIABLES:
var current_mark: Marker3D = null
var tracking_sound: bool = false
var tracking_sound_position: Vector3 = Vector3.ZERO

func _ready() -> void:
	current_state = default_state
	Grabpack.player.sound_manager.connect("sound",Callable(heard_sound))

func _physics_process(delta: float) -> void:
	if current_state == states.disabled: return
	
	if current_state == states.roaming:
		roaming_process(delta)
		move_and_slide()
	elif current_state == states.chase:
		chase_process(delta)
		move_and_slide()
	elif current_state == states.path_follow:
		path_follow_process(delta)

func roaming_process(delta: float) -> void:
	get_sight()
	if current_action == actions.idle: return
	
	if not current_mark:
		var rand_mark = roaming_ai_marks.get_child(randi_range(0, (roaming_ai_marks.get_child_count()-1)))
		current_mark = rand_mark
	nav_agent.target_position = current_mark.global_transform.origin
	if tracking_sound: nav_agent.target_position = tracking_sound_position
	
	move_ai(delta)
func chase_process(delta: float) -> void:
	nav_agent.target_position = Grabpack.player.global_position
	move_ai(delta)
func path_follow_process(delta: float) -> void:
	pass

func move_ai(delta):
	var current_location = global_transform.origin
	var next_location = nav_agent.get_next_path_position()
	var new_velocity = (next_location - current_location).normalized() * get_action_speed()

	prev_look = lerp(prev_look, global_transform.origin + velocity, LERP_SPEED * delta)
	if not global_position==prev_look: look_at(prev_look)
	
	velocity = new_velocity
func set_action(action: actions):
	if action == actions.idle:
		current_action = actions.idle
		current_mark = null
		idle_timer.start(randf_range(idle_time.x, idle_time.y))
		monster_visual.play_animation(actions.idle)
	elif action == actions.walk:
		current_action = actions.walk
		monster_visual.play_animation(actions.walk)
	elif action == actions.run:
		current_action = actions.run
		monster_visual.play_animation(actions.run)

func get_sight():
	var to_player = (Grabpack.player.global_position - global_position).normalized()
	var forward = -transform.basis.z
	var angle_cos = forward.dot(to_player)
	if angle_cos > 0.9:
		raycast.target_position = raycast.to_local(Grabpack.player.global_position)
		if raycast.is_colliding() and raycast.get_collider() == Grabpack.player and global_position.distance_to(Grabpack.player.global_position) < sight_distance:
			current_state = states.chase
			set_action(actions.run)
func heard_sound(sound_name: String = "walk"):
	if current_state == states.roaming:
		if not use_sound_tracking: return
		if current_action == actions.idle: set_action(actions.walk)
		elif randi_range(1, 2) == 1: return
		if sound_name == "walk" and global_position.distance_to(Grabpack.player.global_position) > walk_footstep_distance: return
		if sound_name == "run" and global_position.distance_to(Grabpack.player.global_position) > run_footstep_distance: return
		if sound_name == "jump" and global_position.distance_to(Grabpack.player.global_position) > walk_footstep_distance: return
		if sound_name == "grabpack" and global_position.distance_to(Grabpack.player.global_position) > grabpack_use_distance: return
		tracking_sound = true
		tracking_sound_position = Grabpack.player.position
func get_action_speed():
	if current_action == actions.idle:
		return 0.0
	elif current_action == actions.walk:
		return walk_speed
	elif current_action == actions.run:
		return run_speed
	elif current_action == actions.jumpscare:
		return 0.0

func nav_finished() -> void:
	if default_state == states.roaming:
		tracking_sound = false
		current_state = states.roaming
		set_action(actions.idle)
func idle_finished() -> void:
	if current_state == states.roaming:
		set_action(actions.walk)
