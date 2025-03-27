@tool
extends Control

const SPRITE_SIZE = Vector2(130, 130)
const NONE_WHEEL = preload("res://Interface/Wheel/none_wheel.tres")

@export var bkg_color: Color
@export var line_color: Color
@export var highlight_color: Color

@export var outer_radius: int = 256
@export var inner_radius: int = 64
@export var line_width: int = 4

@export var options: Array[WheelOption]

@onready var label: Label = $Label
@onready var animation_player: AnimationPlayer = $AnimationPlayer

var selection: int = 0

func _unhandled_input(_event: InputEvent) -> void:
	if Engine.is_editor_hint(): return
	if Input.is_action_just_pressed("HandWheel"):
		if not visible:
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			animation_player.play("in")
			show()
			Open()
	elif Input.is_action_just_released("HandWheel"):
		if visible:
			if selection > 0:
				Grabpack.right_hand.switch_hand(1, options[selection].hand_int)
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
			animation_player.play("out")
			await animation_player.animation_finished
			hide()

func Open():
	options = [NONE_WHEEL]
	var hands = Grabpack.right_hand.hands
	for i in hands.size():
		var hand_instance = hands[i].instantiate()
		if hand_instance.name == "None":
			hand_instance.queue_free()
			return
		var new_wheel_option: WheelOption = WheelOption.new()
		var new_icon: Texture2D = hand_instance.get_node("HandInventoryIcon").icon
		new_wheel_option.name = hand_instance.name
		new_wheel_option.atlas = new_icon
		new_wheel_option.region.size = new_icon.get_size()
		new_wheel_option.hand_int = i
		options.append(new_wheel_option)
		hand_instance.queue_free()

func Close():
	return options[selection].name

func _draw() -> void:
	var offset = SPRITE_SIZE / -2
	
	draw_circle(Vector2.ZERO, outer_radius, bkg_color)
	
	if len(options) >= 3:
		
		if selection == 0:
			draw_circle(Vector2.ZERO, inner_radius, highlight_color)
		
		draw_texture_rect_region(
			options[0].atlas,
			Rect2(offset, SPRITE_SIZE),
			options[0].region
		)
		
		for i in range(1, len(options)):
			var start_rads = (TAU * (i-1)) / (len(options) - 1)
			var end_rads = (TAU * i) / (len(options) - 1)
			var mid_rads = (start_rads + end_rads)/2.0 * -1
			var radius_mid = (inner_radius + outer_radius) / 2.0
			
			if selection == i:
				var points_per_arc = 32
				var points_inner = PackedVector2Array()
				var points_outer = PackedVector2Array()
				
				for j in range(points_per_arc+1):
					var angle = start_rads + j * (end_rads - start_rads) / points_per_arc
					points_inner.append(inner_radius * Vector2.from_angle(TAU-angle))
					points_outer.append(outer_radius * Vector2.from_angle(TAU-angle))
				
				points_outer.reverse()
				draw_polygon(
					points_inner + points_outer,
					PackedColorArray([highlight_color])
				)
			
			var draw_pos = radius_mid * Vector2.from_angle(mid_rads) + offset
			draw_texture_rect_region(
				options[i].atlas,
				Rect2(draw_pos, SPRITE_SIZE),
				options[i].region
			)
		
		#DRAW LINES
		for i in range(len(options) - 1):
			var rads = TAU * i / ((len(options) - 1))
			var point = Vector2.from_angle(rads)
			draw_line(
				point*inner_radius,
				point*outer_radius,
				line_color,
				line_width,
				true
			)
	
	#DRAW INNER LINE
	draw_arc(Vector2.ZERO, inner_radius, 0, TAU, 128, line_color, line_width, true)

func _process(_delta: float) -> void:
	var mouse_pos = get_local_mouse_position()
	var mouse_radius = mouse_pos.length()
	
	if mouse_radius < inner_radius:
		selection = 0
	else:
		var mouse_rads = fposmod(mouse_pos.angle() * -1, TAU)
		selection = ceil((mouse_rads / TAU) * (len(options) - 1))
	
	label.text = options[selection].name
	
	queue_redraw()
