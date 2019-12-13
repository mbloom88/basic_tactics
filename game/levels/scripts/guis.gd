extends CanvasLayer

# Signals
signal player_attacking
signal player_waiting

# Child nodes
onready var _menus = $Menus

# Menu info
export (PackedScene) var _player_world_menu
export (PackedScene) var _player_battle_menu

# Actor info
var _actor_in_menu = null

################################################################################
# PRIVATE METHODS
################################################################################

func _add_menu(menu):
	var new_menu = null
	
	match menu:
		'player_world':
			new_menu = _player_world_menu.instance()
			new_menu.connect('menu_requested', self, '_on_Menu_menu_requested')
		'player_battle':
			new_menu = _player_battle_menu.instance()
			new_menu.connect('menu_requested', self, '_on_Menu_menu_requested')
			new_menu.connect('player_attacking', self,
				 '_on_Menu_player_attacking')
			new_menu.connect('player_waiting', self, '_on_Menu_player_waiting')

	new_menu.connect('state_changed', self, '_on_Menu_state_changed')
	_menus.add_child(new_menu)

################################################################################
# PUBLIC METHODS
################################################################################

func show_player_battle_menu(actor):
	_actor_in_menu = actor
	_add_menu('player_battle')

#-------------------------------------------------------------------------------

func show_player_world_menu(actor):
	_actor_in_menu = actor
	_add_menu('player_world')

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_Menu_menu_requested(menu):
	_add_menu(menu)

#-------------------------------------------------------------------------------

func _on_Menu_player_attacking():
	emit_signal('player_attacking')

#-------------------------------------------------------------------------------

func _on_Menu_player_waiting():
	emit_signal('player_waiting')

#-------------------------------------------------------------------------------

func _on_Menu_state_changed(menu, state):
	if state == 'exit':
		_menus.remove_child(menu)
		menu.queue_free()
		
		if _menus.get_child_count() > 0:
			_menus.get_child(get_child_count() - 1).interact()
