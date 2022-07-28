extends Node

var world_state = {}
var sync_clock_counter = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta):
	sync_clock_counter += 1
	if sync_clock_counter == 3:
		sync_clock_counter = 0
		if not get_parent().player_state_collection.empty():
			world_state = get_parent().player_state_collection.duplicate(true)
			for player in world_state.keys():
				world_state[player].erase("T")
			world_state["T"] = OS.get_system_time_msecs()
			#cuts chucks physics checks go here
			get_parent().SendWorldState(world_state)
