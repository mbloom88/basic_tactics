extends Node

# Child nodes
onready var _level = $Level
onready var _menus = $Menus
onready var _menu_delete_timer = $MenuDeleteTimer

# Levels
export (PackedScene) var _new_game_level

# Menus
export (PackedScene) var _main_menu
export (PackedScene) var _player_menu
export (PackedScene) var _squad_loadout

# Actor info
var _actor_in_menu = null

# Menu info
var _menu_queued_for_deletion = null

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
	
	_new_level.connect(
		'player_menu_requested',
		self,
		'_on_Level_player_menu_requested')
	
	_level.add_child(_new_level)

#-------------------------------------------------------------------------------

func _add_menu(menu):
	var new_menu = null
	
	match menu:
		'main':
			new_menu = _main_menu.instance()
			new_menu.connect(
				'new_game_requested',
				self,
				'_on_MainMenu_new_game_requested')
			new_menu.connect('menu_requested', self, '_on_Menu_menu_requested')
		'player':
			new_menu = _player_menu.instance()
			new_menu.connect('menu_requested', self, '_on_Menu_menu_requested')
		'squad_loadout':
			new_menu = _squad_loadout.instance()

	new_menu.connect('state_changed', self, '_on_Menu_state_changed')
	_menus.add_child(new_menu)

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_Level_player_menu_requested(actor):
	_actor_in_menu = actor
	_add_menu('player')

#-------------------------------------------------------------------------------

func _on_MainMenu_new_game_requested():
	_add_level(_new_game_level)

#-------------------------------------------------------------------------------

func _on_Menu_menu_requested(menu):
	match menu:
		'squad_loadout':
			_add_menu(menu)

#-------------------------------------------------------------------------------

func _on_Menu_state_changed(menu, state):
	match state:
		'idle':
			_menus.get_child(_menus.get_child_count() - 1).interact()
		'exit':
			_menu_queued_for_deletion = menu
			_menu_delete_timer.start()

#-------------------------------------------------------------------------------

func _on_MenuDeleteTimer_timeout():
	if is_instance_valid(_menu_queued_for_deletion):
		_menu_delete_timer.start()
	else:
		_menu_queued_for_deletion = null
		
		if _menus.get_child_count() > 0:
			_menus.get_child(_menus.get_child_count() - 1).interact()
		elif _actor_in_menu:
			_actor_in_menu.resume_from_player_menu()
			_actor_in_menu = null
