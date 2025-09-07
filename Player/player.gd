extends CharacterBody3D

@onready var tree = get_tree()  # Cache the tree reference
@onready var sound_manager: Node = $SoundManager  # Cache this node reference

@export_category("Settings")
@export_group("Movement")
@export var movable: bool = true
@export_group("Equipment")
@export_subgroup("Flashlight")
@export var flashlight: bool = false
@export var flashlight_togglable: bool = false
enum mask_types {
	Normal,
	Broken
}
@export_subgroup("Gas Mask")
@export var gasmask: bool = false
@export var gasmask_toggleable: bool = false
@export var gasmask_type: mask_types = mask_types.Normal
@export_subgroup("Grabpack")
@export var hand_speed: float = 24.944
@export var start_lowered: bool = false
#0 is no grabpack, and numbers 1 and 2 are grabpack versions 1 and 2.
@export_range(0, 3) var starting_grabpack: int = 0
@export var enabled_hands: Array [PackedScene] = [preload("res://Player/Grabpack/Hands/none.tscn")]
@export_group("Animation")
enum hand_anims {
	Ch2,
	Ch3,
	Ch4
}
enum grabpack_anims {
	Ch2,
	Ch4
}
@export var hand_switch_animation: hand_anims = hand_anims.Ch4
@export var movement_animations: grabpack_anims = grabpack_anims.Ch4

@export_category("Player")
var speed: float = 10 # m/s
var acceleration: float = 20.24 # m/s^2
var decelleration: float = 50

var normal_speed: float = 2.92
var sprint_speed: float = 6.01
var crouching_speed: float = 1.49
var squeeze_speed: float = 1.0
var speed_lerp: float = 12.0

var jump_height: float = 0.49 # m
var camera_sens: float = 1
var camera_movable: bool = true

var jumping: bool = false
var special_jump: bool = false
var special_jump_height: float = 1.0
var mouse_captured: bool = false

var gravity: float = ProjectSettings.get_setting("physics/3d/default_gravity")

var move_dir: Vector2 # Input direction for movement
var look_dir: Vector2 # Input direction for look/aim

var walk_vel: Vector3 # Walking velocity 
var grav_vel: Vector3 # Gravity velocity 
var jump_vel: Vector3 # Jumping velocity

@onready var neck: Node3D = $Neck
@onready var head = $Neck/Head
@onready var camera = $Neck/Head/CamLayerJump/CamLayerWalk/CamLayerCrouch/Camera3D
@onready var camera_front = $Neck/Head/CamLayerJump/CamLayerWalk/CamLayerCrouch/Camera3D/infront

var player_height: float = 1.7
var crouch_depth: float = 0.85
var crouched: bool = false
var crouch_speed = 2.5
@onready var standing_collision = $StandingCollision
@onready var crouch_collision = $CrouchCollision
@onready var crouch_cast = $RayCast3D

@onready var grabpack = $Grabpack
@onready var animation_manager: Node = $Grabpack/GrabpackAnimationHandler
@onready var crouch_animation: AnimationPlayer = $Grabpack/Pack/CrouchAnimation

#Wire Constraints
@onready var length_calculator: Node = $Grabpack/Pack/LengthCalculator
@onready var left_hand: Node3D = $Grabpack/Pack/LeftHandContainer
@onready var right_hand: Node3D = $Grabpack/Pack/RightHandContainer
@onready var left_wire_container: Node3D = $Grabpack/Pack/LeftWireContainer
@onready var right_wire_container: Node3D = $Grabpack/Pack/RightWireContainer
var wire_1_length:float = 0.0
var wire_2_length:float = 0.0

var is_sprinting: bool = false
var is_squeezing: bool = false
var is_squeeze_hitbox: bool = false

var swinging = false
var swinging_point: Vector3 = Vector3.ZERO
var swinging_time: float = 0.0

var armleftdefaultpos: Vector3 = Vector3(0.444, -0.279, 0.44)
var armrightdefaultpos: Vector3 = Vector3(-0.444, -0.279, 0.44)
var armleftoldpos: Vector3 = Vector3(0.444, -0.279, 0.27)
var armrightoldpos: Vector3 = Vector3(-0.444, -0.279, 0.27)

@onready var hook_controller: HookController = $HookController
@onready var flashlight_node: Node3D = $Neck/Head/CamLayerJump/CamLayerWalk/CamLayerCrouch/Camera3D/Flashlight

func _ready() -> void:
	capture_mouse(true)
	
	Grabpack.reset_objects()
	Game.reset_nodes()
	Grabpack.hud.crosshair.reset_crosshair()
	right_hand.set_hand(0)
	sound_manager.load_soundpack("Concrete")
	
	if GameSettings.mobile_controls:
		if not has_node("MobileControls"):
			var mobile = load("res://Interface/Mobile/mobile_controls.tscn").instantiate()
			mobile.name = "MobileControls"
			Grabpack.player.add_child(mobile)
	
	if movement_animations > 0:
		$Grabpack/Pack/LayerWalk/ArmLeft.position = armleftdefaultpos
		$Grabpack/Pack/LayerWalk/ArmRight.position = armrightdefaultpos
	else:
		$Grabpack/Pack/LayerWalk/ArmLeft.position = armleftoldpos
		$Grabpack/Pack/LayerWalk/ArmRight.position = armrightoldpos

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		if not movable: return
		look_dir = event.relative * 0.001
		if mouse_captured: if camera_movable: _rotate_camera()
	if Input.is_action_just_pressed("jump") and movable: jumping = true
func touch_dragged(delta: Vector2) -> void:
	if not movable or not camera_movable: return

	look_dir = delta * 0.001  # match mouse sens scale
	_rotate_camera()

func _physics_process(delta: float) -> void:
	if not movable: return
	camera_sens = GameSettings.camera_sens/30
	#Handle Crouch:
	var crouchable: bool = false
	if Input.is_action_pressed("crouch"):
		if not is_squeezing:
			crouchable = true
	if crouch_cast.is_colliding():
		crouchable = true
	if (crouch_animation.is_playing() and crouch_animation.current_animation == "EnterCrouch"):
		crouchable = true
	if (crouch_animation.is_playing() and crouch_animation.current_animation == "ExitCrouch"):
		crouchable = false
	
	if crouchable:
		standing_collision.disabled = true
		crouch_collision.disabled = false
		
		#neck.position.y = move_toward(neck.position.y, crouch_depth, (crouch_speed) * delta)
		grabpack.position.y = neck.position.y
		crouched = true
	else:
		if not crouch_cast.is_colliding():
			standing_collision.disabled = false
			crouch_collision.disabled = true
			
			#neck.position.y = move_toward(neck.position.y, player_height, crouch_speed * delta)
			grabpack.position.y = neck.position.y
			crouched = false
	
	#Handle Sprinting:
	is_sprinting = Input.is_action_pressed("sprint")
	
	#Handle Speed:
	if crouched:
		speed = lerp(speed, crouching_speed, speed_lerp * delta)
	elif is_squeezing:
		speed = lerp(speed, squeeze_speed, speed_lerp * delta)
	elif is_sprinting:
		speed = lerp(speed, sprint_speed, speed_lerp * delta)
	else:
		speed = lerp(speed, normal_speed, speed_lerp * delta)
	
	if is_squeezing != is_squeeze_hitbox:
		standing_collision.shape.radius = 0.19 if is_squeezing else 0.3
		is_squeeze_hitbox = is_squeezing
	
	if mouse_captured: _handle_joypad_camera_rotation(delta)
	if not swinging: 
		swinging_time = 0.0
		velocity = _walk(delta) + _gravity(delta) + _jump(delta)
	elif is_on_floor(): velocity = _walk(delta) + _gravity(delta) + _jump(delta)
	else:
		if not $SoundManager/Swing.playing: $SoundManager/Swing.play()
		swinging_time += 1.0*delta
		if swinging_time < 0.21:
			velocity = _walk(delta) + _gravity(delta) + _jump(delta)
		else:
			jump_vel = velocity
			jump_vel.y = velocity.y * 1.5
			if jump_vel.y > 9.0:
				jump_vel.y = 9.0
	
	if not left_hand.hand_attached or not right_hand.hand_attached:
		# Simulate the new position
		var max_total_length: float = length_calculator.max_length
		var desired_velocity: Vector3 = velocity  # Example speed
		#var current_position = global_position
		
		wire_1_length = left_wire_container.get_wire_distance()
		wire_2_length = right_wire_container.get_wire_distance()
		var total_length: float = wire_1_length + wire_2_length
		
		# Prevent exceeding max length
		if total_length > max_total_length:
			var hand_limits: bool = false
			if left_hand.hand_travelling:
				left_hand.retract_hand()
				hand_limits = true
			if right_hand.hand_travelling:
				right_hand.retract_hand()
				hand_limits = true
			if not hand_limits:
				var excess_length: float = total_length - max_total_length
		
				# Find the direction toward the center point between anchors
				var direction_to_center: Vector3 = ((left_wire_container.get_wire_second() + right_wire_container.get_wire_second()) / 2 - global_position).normalized()
		
				# Apply a correction that keeps the player within the allowed range
				global_position += direction_to_center * excess_length
		
				# Stop movement when max length is reached
				velocity = Vector3.ZERO  
		else:
			# Apply movement normally if within bounds
			velocity.x = desired_velocity.x
			velocity.z = desired_velocity.z

	move_and_slide()
	
	#Handle Flashlight
	flashlight_node.visible = flashlight
	
	#Settings Update:
	camera.fov = GameSettings.fov

func capture_mouse(capture_mode: bool) -> void:
	if capture_mode:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = capture_mode
func release_mouse() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	mouse_captured = false
func _rotate_camera(sens_mod: float = 1.0) -> void:
	neck.rotation.y -= look_dir.x * camera_sens * sens_mod
	neck.rotation.x = clamp(neck.rotation.x - look_dir.y * camera_sens * sens_mod, -1.5, 1.5)
func _handle_joypad_camera_rotation(delta: float, sens_mod: float = 1.0) -> void:
	var joypad_dir: Vector2 = Input.get_vector(&"look_left", &"look_right", &"look_up", &"look_down")
	if joypad_dir.length() > 0:
		camera_sens *= 2.0
		look_dir += joypad_dir * delta
		_rotate_camera(sens_mod)
		look_dir = Vector2.ZERO
func _walk(delta: float) -> Vector3:
	move_dir = Input.get_vector("left", "right", "forward", "back")
	var _forward: Vector3 = neck.global_transform.basis * Vector3(move_dir.x, 0, move_dir.y)
	var walk_dir: Vector3 = Vector3(_forward.x, 0, _forward.z).normalized()
	walk_vel = walk_vel.move_toward(walk_dir * speed * move_dir.length(), (acceleration if move_dir != Vector2.ZERO else decelleration) * delta)
	return walk_vel
func _gravity(delta: float) -> Vector3:
	grav_vel = Vector3.ZERO if is_on_floor() else grav_vel.move_toward(Vector3(0, velocity.y - gravity, 0), gravity * delta)
	return grav_vel
func _jump(delta: float) -> Vector3:
	if jumping:
		if special_jump:
			jump_vel = Vector3(0, sqrt(4 * special_jump_height * gravity), 0)
			animation_manager.jump()
		elif is_on_floor():
			var can_jump: bool = true
			if crouch_cast.is_colliding():
				can_jump = false
			if is_squeezing:
				can_jump = false
			
			if can_jump:
				jump_vel = Vector3(0, sqrt(4 * jump_height * gravity), 0)
				animation_manager.jump()
		jumping = false
		special_jump = false
		return jump_vel
	jump_vel = Vector3.ZERO if is_on_floor() else jump_vel.move_toward(Vector3.ZERO, gravity * delta)
	return jump_vel

func external_jump(height: float):
	jumping = true
	special_jump = true
	special_jump_height = height
