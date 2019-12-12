extends Node

# Child nodes
onready var _level = $Level
onready var _menus = $Menus

################################################################################
# VIRTUAL METHODS
################################################################################

func _ready():
	_menus.start_default_menu()

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_Level_player_menu_requested(actor, type):
	_menus.show_player_menu(actor, type)

#-------------------------------------------------------------------------------

func _on_Menus_new_game_requested():
	_level.start_new_game()
