extends KinematicBody2D

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

const GRAVITY_VEC = Vector2(0, 900)
var linear_vel = Vector2()


onready var player = get_tree().root.get_node("Game/Louie")

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	if global_position.x < player.position.x:
		get_node("AnimatedSprite").scale.x = 1
	else:
		get_node("AnimatedSprite").scale.x = -1
		
	linear_vel += delta * GRAVITY_VEC
		
	linear_vel = move_and_slide(linear_vel, Vector2(0, -1), 5.0)
		
		
	pass
