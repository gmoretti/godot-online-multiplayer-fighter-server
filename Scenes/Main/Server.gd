extends Node

var network = NetworkedMultiplayerENet.new()
var port = 60090
var max_players = 100

var player_state_collection = {}

# Lobby and Waitin Roon variables
var players = {}
var ready_players = 0

var game_started = false

const spawn_position_available_default = [Vector2(550,400), Vector2(550,100), Vector2(650,400),  Vector2(700,200)]
const available_colors_default = [Color("ED6A5A"),Color("fff200"),Color("3F8A5F"),Color("5CA4E3"),Color("E677E0")]

var spawn_position_available = spawn_position_available_default.duplicate()
var available_colors = available_colors_default.duplicate()

# Called when the node enters the scene tree for the first time.
func _ready():
	StartServer()
	
func StartServer():
	print("Trying")
	network.create_server(port, max_players)
	get_tree().set_network_peer(network)
	print("Server Started")
	
	network.connect("peer_connected", self, "_Peer_Connected")
	network.connect("peer_disconnected", self, "_Peer_Disconnected")
	
func _Peer_Connected(player_id):
	print("User " + str(player_id) + " Connected")
	#var spawn_position = Vector2(550,400)
	# Initialize State
	# Spawn player at server
	#get_node("World").SpawnPlayer(player_id, spawn_position)
	# Inform spawn to clients
	#rpc_id(0, "SpawnPlayer", player_id, spawn_position)
	
func _Peer_Disconnected(player_id):
	print("User " + str(player_id) + " Disconnected")
	remove_player_info(player_id)
	if game_started == true:
		player_state_collection.erase(player_id)
		# Spawn player at server
		get_node("World").DispawnPlayer(player_id)
		rpc_id(0, "DispawnPlayer", player_id)
	if players.size() == 0:
		reset_room()
		
func reset_room():
	game_started = false
	spawn_position_available = spawn_position_available_default.duplicate()
	available_colors = available_colors_default.duplicate()
	player_state_collection = {}
	# Lobby and Waitin Roon variables
	players = {}
	ready_players = 0
	network.refuse_new_connections = false
	
remote func getData(requested_data, requester):
	var player_id = get_tree().get_rpc_sender_id()
	var data = ServerData.some_data[requested_data]
	rpc_id(player_id,"returnData", data, requester)
	print("sending " + str(data) + " to player")

remote func ReceivePlayerState(player_state):
	var player_id = get_tree().get_rpc_sender_id()
	if player_state_collection.has(player_id):
		if player_state_collection[player_id]["T"] < player_state["T"]:
			player_state_collection[player_id] = player_state
	else:
		player_state_collection[player_id] = player_state
	# Spawn player at server
	get_node("World").ProcessPlayerState(player_id, player_state)

func SendWorldState(world_state):
	rpc_unreliable_id(0, "ReceiveWorldState", world_state)
	
remote func FetchServerTime(client_time):
	var player_id = get_tree().get_rpc_sender_id()
	rpc_id(player_id, "ReturnServerTime", OS.get_system_time_msecs(), client_time)
	
remote func DetermineLatency(client_time):
	var player_id = get_tree().get_rpc_sender_id()
	#print(client_time," ", OS.get_system_time_msecs())
	rpc_id(player_id, "ReturnLatency", client_time)

remote func Attack(position, direction, spawn_time):
	var player_id = get_tree().get_rpc_sender_id()
	get_node("World").SpawnAttack(spawn_time, position, direction, player_id)
	rpc_id(0, "ReceiveAttack", position, direction, spawn_time, player_id)
	
# In reality sends Health to avoid tampering
func SendDamage(health, player_id):
	rpc_id(0, "ReceiveDamage", health, OS.get_system_time_msecs(), player_id)
	
func KillPlayer(player_id):
	rpc_id(0, "ReceiveKillPlayer", OS.get_system_time_msecs(), player_id)

# Lobby and waiting roon code
remote func send_player_info(id, player_data):
	# Max player check TODO th is should be better
	if !spawn_position_available.empty():
		players[id] = player_data
		rset("players", players)
		rpc("update_waiting_room")
	
func remove_player_info(player_id):
	players.erase(player_id)
	rset("players", players)
	rpc("update_waiting_room")
	
remote func load_world():
	ready_players += 1
	if players.size() > 0 and ready_players >= players.size():
		game_started = true
		# This is needed to avoid crashing in clients when game already started
		network.refuse_new_connections = true
		rpc("start_game")
		spawn_players()
		
func spawn_players():
	for player_id in players:
		var spawn_position = spawn_position_available.pop_front()
		var color = available_colors.pop_front()
		# Initialize State
		# Spawn player at server
		get_node("World").SpawnPlayer(player_id, spawn_position)
		# Inform spawn to clients
		rpc_id(0, "SpawnPlayer", player_id, spawn_position, color)
