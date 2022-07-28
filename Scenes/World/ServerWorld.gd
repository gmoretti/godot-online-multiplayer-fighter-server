extends Node2D

var bullet = preload("res://Scenes/Weapons/Projectiles/ServerGunBullet.tscn")
var enemy_list = []
var open_locations = []
var occupied_locations = {}

var player_spawn = preload("res://Scenes/Characters/ServerPlayerTemplate.tscn")
var player_list = []
var player_spawn_points = []


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func SpawnAttack(spawn_time, position, direction, player_id):
	var bullet_instance = bullet.instance()
	bullet_instance.player_id = player_id
	bullet_instance.position = position
	bullet_instance.direction = direction
	add_child(bullet_instance)

func NPCHit(enemy_id, damage):
	if enemy_list[enemy_id]["EnemyHealth"] <= 0:
		pass
	else:
		enemy_list[enemy_id]["EnemyHealth"] = enemy_list[enemy_id]["EnemyHealth"] - damage
		if enemy_list[enemy_id]["EnemyHealth"] <= 0:
			#get_node("/root/ServerWorld/Enemies/" + srt(enemy_id)).queue_free() #This would work if we had Npc Enemy node
			enemy_list[enemy_id]["EnemyState"] = "Dead"
			open_locations.append(occupied_locations[enemy_id])
			occupied_locations.erase(enemy_id)

func SpawnPlayer(player_id, spawn_position):
	if not get_node("OtherPlayers").has_node(str(player_id)):
		var new_player = player_spawn.instance()
		new_player.position = spawn_position
		new_player.name = str(player_id)
		get_node("./OtherPlayers").add_child(new_player)
		
func DispawnPlayer(player_id):
	yield(get_tree().create_timer(0.2), "timeout")
	get_node("./OtherPlayers/" + str(player_id)).queue_free()
	
func ProcessPlayerState(player_id, player_state):
	get_node("OtherPlayers/" + str(player_id)).MovePlayer(player_state["P"], player_state["A"])
	
func PlayerHit(player_id, damage):
	print("playerHit")
	var player_state = get_parent().player_state_collection.get(player_id)
	var player_node = get_node("OtherPlayers/" + str(player_id))
	player_node.current_hp = player_node.current_hp - 10
	player_node.SetHealthLabel()
	get_parent().SendDamage(player_node.current_hp, player_id)
