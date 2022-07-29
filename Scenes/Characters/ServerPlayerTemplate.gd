extends KinematicBody2D

var max_hp = 100
var current_hp
var dead = false

func _ready():
	current_hp = max_hp
	$Health.text = str(current_hp) + "%"

func MovePlayer(new_position, animation_vector):
	set_position(new_position)
	$Sprite.scale.x = animation_vector.y
	
func SetHealthLabel():
	$Health.text = str(current_hp) + "%"
