extends Node

# Child nodes
onready var _level = $Level
onready var _menus = $Menus

################################################################################
# BUILT-IN VIRTUAL METHODS
################################################################################

func _ready():
	_menus.start_default_menu()

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_Menus_new_game_requested():
	_level.start_new_game()
