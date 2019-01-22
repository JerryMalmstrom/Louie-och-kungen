extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

var outfit = 0

onready var sprite = get_node("Node2D/Sprite")
onready var hat = get_node("Node2D/Hat")
var hat_var = 0
onready var eyes = get_node("Node2D/Eyes")
var eyes_var = 0
onready var clothes = get_node("Node2D/Clothes")
var clothes_var = 0


# Called when the node enters the scene tree for the first time.
func _ready():
	$Node2D/AnimationPlayer.play("Idle")
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Quit_pressed():
	get_tree().quit()
	
	pass # Replace with function body.


func _on_Start_pressed():
	get_tree().change_scene("Game.tscn")
	pass # Replace with function body.


func _on_Options_pressed():
	
	pass # Replace with function body.


func _on_Outfit_pressed():
	outfit += 1
	if outfit > 4:
		outfit = 0
	
	"""	
	match outfit:
		0:
			decoration.texture = load("res://only-empty.png")
		1:
			decoration.texture = load("res://only-bandana.png")
		2:
			decoration.texture = load("res://only-glasses.png")
		3:
			decoration.texture = load("res://only-shades.png")
		4:
			decoration.texture = load("res://only-clothes.png")
	
	"""
	globals.outfit = outfit
	pass # Replace with function body.


func _on_Hat_next_pressed():
	hat.texture = load("res://only-empty.png")
	pass # Replace with function body.


func _on_Hat_prev_pressed():
	hat.texture = load("res://only-bandana.png")
	pass # Replace with function body.

func _on_Clothes_next_pressed():
	clothes.texture = load("res://only-empty.png")
	pass # Replace with function body.

func _on_Clothes_prev_pressed():
	clothes.texture = load("res://only-clothes.png")
	pass # Replace with function body.

func _on_Eyes_next_pressed():
	eyes_var = clamp(eyes_var+1, 0, 2)
	
	match eyes_var:
		0:
			eyes.texture = load("res://only-empty.png")
		1:
			eyes.texture = load("res://only-glasses.png")
		2:
			eyes.texture = load("res://only-shades.png")
	
	pass # Replace with function body.


func _on_Eyes_prev_pressed():
	eyes_var = clamp(eyes_var-1, 0, 2)
	
	match eyes_var:
		0:
			eyes.texture = load("res://only-empty.png")
		1:
			eyes.texture = load("res://only-glasses.png")
		2:
			eyes.texture = load("res://only-shades.png")
	
	pass # Replace with function body.
