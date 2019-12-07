extends Node

# Child nodes
onready var _actor_db = $ActorDatabase
onready var _level = $Level
onready var _menus = $Menus

# User-defined assets
export (PackedScene) var _main_menu
export (PackedScene) var _new_game_level

################################################################################
# VIRTUAL METHODS
################################################################################

func _ready():
	_add_menu('main')

################################################################################
# PRIVATE METHODS
################################################################################

func _add_level(level):
	var _new_level = level.instance()
	
	_level.add_child(_new_level)

#-------------------------------------------------------------------------------

func _add_menu(menu):
	var new_menu = null
	
	match menu:
		'main':
			new_menu = _main_menu.instance()
			new_menu.connect("new_game_requested", self, \
				"_on_MainMenu_new_game_requested")
	
	new_menu.connect("state_changed", self, "_on_Menu_state_changed")
	
	_menus.add_child(new_menu)

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_MainMenu_new_game_requested():
	_add_level(_new_game_level)

#-------------------------------------------------------------------------------

func _on_Menu_state_changed(menu, state):
	match state:
		'idle':
			menu.interact()
