extends Node

# Signals
signal player_menu_requested(actor, type)

# Level info
export (PackedScene) var _new_game_level

################################################################################
# PRIVATE METHODS
################################################################################

func _add_level(level):
	var new_level = level.instance()
	
	new_level.connect(
		'player_menu_requested',
		self,
		'_on_Level_player_menu_requested')
	
	add_child(new_level)

################################################################################
# PUBLIC METHODS
################################################################################

func start_new_game():
	_add_level(_new_game_level)

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_Level_player_menu_requested(actor, type):
	emit_signal('player_menu_requested', actor, type)
