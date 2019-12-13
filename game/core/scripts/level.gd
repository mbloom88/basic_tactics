extends Node

# Level info
export (PackedScene) var _new_game_level

################################################################################
# PRIVATE METHODS
################################################################################

func _add_level(level):
	var new_level = level.instance()
	add_child(new_level)

################################################################################
# PUBLIC METHODS
################################################################################

func start_new_game():
	_add_level(_new_game_level)
