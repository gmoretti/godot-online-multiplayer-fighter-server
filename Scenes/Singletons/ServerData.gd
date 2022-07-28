extends Node

var some_data

# Declare member variables here. Examples:
# var a = 2
# var b = "text"


# Called when the node enters the scene tree for the first time.
func _ready():
	var game_data_file = File.new()
	game_data_file.open("res://Data/data.json", File.READ)
	var game_data_json = JSON.parse(game_data_file.get_as_text())
	game_data_file.close() # Replace with function body.
	
	some_data = game_data_json.result


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
