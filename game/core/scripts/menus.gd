extends CanvasLayer

# Signals
signal new_game_requested

# Child nodes
onready var _menu_delete_timer = $MenuDeleteTimer

# Menu info
export (PackedScene) var _main_menu
export (PackedScene) var _player_world_menu
export (PackedScene) var _player_battle_menu
export (PackedScene) var _squad_loadout
var _menu_queued_for_deletion = null

# Actor info
var _actor_in_menu = null

################################################################################
# PRIVATE METHODS
################################################################################

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
		'player_world':
			new_menu = _player_world_menu.instance()
			new_menu.connect('menu_requested', self, '_on_Menu_menu_requested')
		'player_battle':
			new_menu = _player_battle_menu.instance()
			new_menu.connect('menu_requested', self, '_on_Menu_menu_requested')
		'squad_loadout':
			new_menu = _squad_loadout.instance()

	new_menu.connect('state_changed', self, '_on_Menu_state_changed')
	add_child(new_menu)

################################################################################
# PUBLIC METHODS
################################################################################

func show_player_menu(actor, type):
	_actor_in_menu = actor
	match type:
		'battle':
			_add_menu('player_battle')
		'world':
			_add_menu('player_world')

#-------------------------------------------------------------------------------

func show_player_world_menu(actor):
	_actor_in_menu = actor
	_add_menu('player_world')

#-------------------------------------------------------------------------------

func start_default_menu():
	_add_menu('main')

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_MainMenu_new_game_requested():
	emit_signal('new_game_requested')

#-------------------------------------------------------------------------------

func _on_Menu_menu_requested(menu):
	_add_menu(menu)

#-------------------------------------------------------------------------------

func _on_Menu_state_changed(menu, state):
	if state == 'exit':
		_menu_queued_for_deletion = menu
		_menu_delete_timer.start()

#-------------------------------------------------------------------------------

func _on_MenuDeleteTimer_timeout():
	if is_instance_valid(_menu_queued_for_deletion):
		_menu_delete_timer.start()
	else:
		_menu_queued_for_deletion = null
		
		if get_child_count() > 1:
			get_child(get_child_count() - 1).interact()
		elif _actor_in_menu:
			_actor_in_menu.resume_from_player_menu()
			_actor_in_menu = null
