extends KinematicBody2D

const GRAVITY_VEC = Vector2(0, 900)
const FLOOR_NORMAL = Vector2(0, -1)
const SLOPE_SLIDE_STOP = 5.0

const MIN_ONAIR_TIME = 0.1
const PUNCH_TIME_SHOW = 0.6
const SLASH_TIME_SHOW = 0.5

const WALK_SPEED = 100 # pixels/sec
const RUN_SPEED = 250
const JUMP_SPEED = 250
const SIDING_CHANGE_SPEED = 10

var linear_vel = Vector2()

var onair_time = 0.0
var punch_time = 5.0
var slash_time = 5.0
var water_time = 0.0

var on_floor = false
var on_ladder = false
var in_water = false

var climb_down = false
var climb_up = false

var anim=""
var speed = 0
var HP = 100
var outfit = 0

onready var sprite = get_node("AnimatedSprite")
onready var swoosh = get_node("Swoosh")
onready var animator = get_node("AnimationPlayer")
#onready var tilemapTop = get_parent().get_node("Top")



onready var dust_res = preload("res://DustRun.tscn")
var dust

signal hurt

func change_outfit(number):
	match number:
		0:
			$Decoration.texture = load("res://only-empty.png")
		1:
			$Decoration.texture = load("res://only-bandana.png")
		2:
			$Decoration.texture = load("res://only-glasses.png")
		3:
			$Decoration.texture = load("res://only-shades.png")
		4:
			$Decoration.texture = load("res://only-clothes.png")


# Called when the node enters the scene tree for the first time.
func _ready():
	outfit = globals.outfit
	change_outfit(outfit)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	var new_anim = "Idle"
	_handle_input()	
	
	on_ladder = get_tile_on_position(position) == "ladder"
	
	onair_time += delta
	punch_time += delta
	slash_time += delta
	if in_water:
		water_time += delta
	else:
		water_time = 0
	
	
	# Apply Gravity
	linear_vel += delta * GRAVITY_VEC
	# Move and Slide
	
	# Detect Floor
	if is_on_floor():
		onair_time = 0
		
	if is_on_wall():
		onair_time = 0

	on_floor = onair_time < MIN_ONAIR_TIME
	
	if on_floor:
		if linear_vel.x < -SIDING_CHANGE_SPEED:
			sprite.scale.x = -1
			swoosh.scale.x = -0.5
			new_anim = "Walk" if speed == WALK_SPEED else "Run"
			
		elif linear_vel.x > SIDING_CHANGE_SPEED:
			sprite.scale.x = 1
			swoosh.scale.x = 0.5
			new_anim = "Walk" if speed == WALK_SPEED else "Run"
	else:
		
		# We want the character to immediately change facing side when the player
		# tries to change direction, during air control.
		# This allows for example the player to shoot quickly left then right.
		if Input.is_action_pressed("move_left") and not Input.is_action_pressed("move_right"):
			sprite.scale.x = -1
			swoosh.scale.x = -0.5
		if Input.is_action_pressed("move_right") and not Input.is_action_pressed("move_left"):
			sprite.scale.x = 1
			swoosh.scale.x = 0.5

		if linear_vel.y < 0:
			new_anim = "Jump"
		else:
			new_anim = "Fall"
			
			
	if punch_time < PUNCH_TIME_SHOW:
		new_anim = "Punch"
		
	if slash_time < SLASH_TIME_SHOW:
		new_anim = "Slash"
		swoosh.play("slash")
	else:
		swoosh.play("default")
		
	if climb_up:
		new_anim = "Climb"
		var pos = get_position()
		pos.y = pos.y - 1
		set_position(pos)
	elif climb_down:
		new_anim = "Climb"
		var pos = get_position()
		pos.y = pos.y + 1
		set_position(pos)
	elif in_water:
		sprite.modulate = Color(0.5,0.5,1)
		new_anim = "Idle"
		rotation_degrees = lerp(rotation_degrees,-90,0.05)
#		position.y += 1
		if water_time > 1:
			HP -= 20
			emit_signal("hurt",HP)
			water_time = 0
		new_anim = "Hurt"
		move_and_slide(Vector2(0,20))
		
	else:
		linear_vel = move_and_slide(linear_vel, FLOOR_NORMAL, SLOPE_SLIDE_STOP)
		
		
	if new_anim != anim:
		anim = new_anim
#		sprite.play(anim)
		animator.play(anim)

func _handle_input():
	var target_speed = 0
	if Input.is_action_pressed("move_left"):
		target_speed += -1
	if Input.is_action_pressed("move_right"):
		target_speed +=  1
		
		
	if Input.is_action_pressed("move_up") and on_ladder:
		climb_up = true
		climb_down = false
	elif Input.is_action_pressed("move_down") and on_ladder:
		climb_up = false
		climb_down = true
	else:
		climb_up = false
		climb_down = false
		
		
	if Input.is_action_just_pressed("ui_left"):
		outfit = clamp(outfit-1, 0, 4)
		change_outfit(outfit)
	elif Input.is_action_just_pressed("ui_right"):
		outfit = clamp(outfit+1, 0, 4)
		change_outfit(outfit)

	if Input.is_action_pressed("run"):
		speed = RUN_SPEED
	else:
		speed = WALK_SPEED

	target_speed *= speed
	linear_vel.x = lerp(linear_vel.x, target_speed, 0.1)

	# Jumping
	if on_floor and Input.is_action_just_pressed("jump"):
		if speed == WALK_SPEED:
			linear_vel.y = -JUMP_SPEED
		elif speed == RUN_SPEED:
			linear_vel.y = -(JUMP_SPEED*1.2)
			
		dust = dust_res.instance()
		dust.position = $Feet.position
		self.add_child(dust)
#		$sound_jump.play()
		
	# Punch
	if Input.is_action_just_pressed("punch") and punch_time > PUNCH_TIME_SHOW:
		punch_time = 0
		
	if Input.is_action_just_pressed("slash") and slash_time > SLASH_TIME_SHOW:
		slash_time = 0
		
		
func get_tile_on_position(pos):
	var tilemap = get_parent().get_node("Top")
	if not tilemap == null:
		var map_pos = tilemap.world_to_map(pos)
		var id = tilemap.get_cellv(map_pos)
		if id > -1:
			var tilename = tilemap.get_tileset().tile_get_name(id)
			return tilename
		else:
			return ""



func _on_HPProgress_value_changed(value):
	if value <= 0:
		get_tree().reload_current_scene()
	pass # Replace with function body.
