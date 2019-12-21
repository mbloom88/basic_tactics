extends CanvasLayer

# Signals
signal battler_skills_requested
signal player_waiting
signal skill_selected(skill)
signal weapon_changed

# Child nodes
onready var _menus = $Menus
onready var _battle_gui = $BattleGUI

# Menu info
export (PackedScene) var _player_world_menu
export (PackedScene) var _player_battle_menu
export (PackedScene)  var _skills_menu

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
			new_menu.set_actor(_actor_in_menu)
			new_menu.connect('menu_requested', self, '_on_Menu_menu_requested')
			new_menu.connect('player_browsing_skills', self, 
				'_on_PlayerBattleMenu_player_browsing_skills')
			new_menu.connect('player_waiting', self, 
				'_on_PlayerBattleMenu_player_waiting')
		'skills_menu':
			new_menu = _skills_menu.instance()
			new_menu.connect('skill_selected', self, 
				'_on_SkillMenu_skill_selected')

	new_menu.connect('state_changed', self, '_on_Menu_state_changed')
	_menus.add_child(new_menu)

################################################################################
# PUBLIC METHODS
################################################################################

func add_skills_to_list(skills):
	var last_index = _menus.get_child_count() - 1
	var last_menu = _menus.get_child(last_index)
	
	if last_menu.has_method('add_skills_to_list'):
		last_menu.add_skills_to_list(skills)

#-------------------------------------------------------------------------------

func hide_active_actor_gui():
	_battle_gui.hide_active_actor_gui()

#-------------------------------------------------------------------------------

func hide_ally_select_gui():
	_battle_gui.hide_ally_select_gui()

#-------------------------------------------------------------------------------

func hide_target_actor_gui():
	_battle_gui.hide_target_actor_gui()

#-------------------------------------------------------------------------------

func hide_weapon_status():
	_battle_gui.hide_weapon_status()

#-------------------------------------------------------------------------------

func load_active_actor_info(actor):
	_battle_gui.load_active_actor_info(actor)

#-------------------------------------------------------------------------------

func load_target_actor_info(actor):
	_battle_gui.load_target_actor_info(actor)

#-------------------------------------------------------------------------------

func load_weapon_info(weapon1, weapon2):
	_battle_gui.load_weapon_info(weapon1, weapon2)

#-------------------------------------------------------------------------------

func refresh_weapon_info():
	_battle_gui.refresh_weapon_info()

#-------------------------------------------------------------------------------

func remove_all_menus():
	var menu_list = _menus.get_children()
	for menu in range(_menus.get_child_count()):
		var exiting_menu = menu_list.pop_back()
		_menus.remove_child(exiting_menu)
		exiting_menu.queue_free()

#-------------------------------------------------------------------------------

func resume_last_menu():
	if _menus.get_child_count() > 0:
		_menus.get_children().back().interact()

#-------------------------------------------------------------------------------

func show_active_actor_gui():
	_battle_gui.show_active_actor_gui()

#-------------------------------------------------------------------------------

func show_ally_select_gui():
	_battle_gui.show_ally_select_gui()

#-------------------------------------------------------------------------------

func show_player_battle_menu(actor):
	_battle_gui.deactivate_weapon_swap()
	_actor_in_menu = actor
	_add_menu('player_battle')

#-------------------------------------------------------------------------------

func show_player_world_menu(actor):
	_actor_in_menu = actor
	_add_menu('player_world')

#-------------------------------------------------------------------------------

func show_target_actor_gui(target):
	_battle_gui.show_target_actor_gui()

#-------------------------------------------------------------------------------

func show_weapon_status():
	_battle_gui.show_weapon_status()
	_battle_gui.activate_weapon_swap()

#-------------------------------------------------------------------------------

func update_current_weapon(current_weapon):
	_battle_gui.update_current_weapon(current_weapon)

#-------------------------------------------------------------------------------

func update_squad_count():
	_battle_gui.update_squad_count()

#-------------------------------------------------------------------------------

func update_squad_status(type):
	_battle_gui.update_squad_status(type)

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_BattleGUI_weapon_changed():
	emit_signal('weapon_changed')

#-------------------------------------------------------------------------------

func _on_Menu_menu_requested(menu):
	_add_menu(menu)

#-------------------------------------------------------------------------------

func _on_PlayerBattleMenu_player_browsing_skills():
	_add_menu('skills_menu')

#-------------------------------------------------------------------------------

func _on_PlayerBattleMenu_player_waiting():
	_actor_in_menu = null
	emit_signal('player_waiting')

#-------------------------------------------------------------------------------

func _on_SkillMenu_skill_selected(skill):
	emit_signal('skill_selected', skill)

#-------------------------------------------------------------------------------

func _on_Menu_state_changed(menu, state):
	if state == 'interact':
		match menu.name:
			'SkillsMenu':
				emit_signal('battler_skills_requested')
	if state == 'exit':
		match menu.name:
			'PlayerWorldMenu':
				menu.disconnect('menu_requested', self,
					'_on_Menu_menu_requested')
			'PlayerBattleMenu':
				_battle_gui.activate_weapon_swap()
				menu.disconnect('menu_requested', self, 
					'_on_Menu_menu_requested')
				menu.disconnect('player_browsing_skills', self, 
				'_on_PlayerBattleMenu_player_browsing_skills')
				menu.disconnect('player_waiting', self, 
					'_on_PlayerBattleMenu_player_waiting')
				if _actor_in_menu:
					_actor_in_menu.resume_from_player_menu()
			'SkillsMenu':
				menu.disconnect('skill_selected', self, 
				'_on_SkillMenu_skill_selected')
		menu.disconnect('state_changed', self, '_on_Menu_state_changed')
		_menus.remove_child(menu)
		menu.queue_free()
		resume_last_menu()
