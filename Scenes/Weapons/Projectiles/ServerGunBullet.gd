extends RigidBody2D

var projectile_speed = 1500
var direction = Vector2()
var life_time = 3
var original = true
var player_id
var damage

# Called when the node enters the scene tree for the first time.
func _ready():
	SetDamage()
	apply_impulse(Vector2(), direction * projectile_speed)
	#apply_impulse(Vector2(), Vector2(projectile_speed, 0).rotated(rotation))
	SelfDistruct()
	
func SetDamage():
	damage = 10
	
func SelfDistruct():
	yield(get_tree().create_timer(life_time), "timeout")
	queue_free()

func _on_Bullet_body_entered(body):
	get_node("CollisionShape2D").set_deferred("disabled", true)
	print("HEre " + body.name)
	# print("HEre " + body.groups)
	
	if body.is_in_group("Players"):
		print("HEre2")
		var player_id = int(body.get_name())
		get_node("/root/Server/World").PlayerHit(player_id, damage)
	self.hide() #this is not working, check!
