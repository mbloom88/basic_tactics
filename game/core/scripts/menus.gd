extends CanvasLayer

# Signals
signal new_game_requested

# Menu info
export (PackedScene) var _main_menu

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

	new_menu.connect('state_changed', self, '_on_Menu_state_changed')
	add_child(new_menu)

################################################################################
# PUBLIC METHODS
################################################################################

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
		remove_child(menu)
		menu.queue_free()
		
		if get_child_count() > 0:
			get_child(get_child_count() - 1).interact()
