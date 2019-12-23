"""
Base 'Level' scene.
"""
extends Node2D

# Child nodes
onready var _camera = $Camera
onready var _battleground = $Battleground
onready var _guis = $GUIs
onready var _battle_gui = $GUIs/BattleGUI
onready var _cell_vectors = $Debug/CellVectors
onready var _command = $CommandPrograms

################################################################################
# VIRTUAL METHODS
################################################################################

func _ready():
	_provide_debug_info()
	
	if _command.get_children():
		_command.get_child(0).initialize()

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_Battleground_active_actor_selected(actor):
	_guis.load_active_actor_gui(actor)

#-------------------------------------------------------------------------------

func _on_Battleground_allies_ready_for_placement():
	_guis.show_ally_select_gui()
	_battleground.place_actors()

#-------------------------------------------------------------------------------

func _on_Battleground_battle_action_cancelled():
	_guis.resume_last_menu()

#-------------------------------------------------------------------------------

func _on_Battleground_battle_turn_completed():
	_guis.remove_all_menus()
	_guis.hide_target_actor_gui()
	_guis.hide_active_actor_gui()
	_guis.hide_weapon_gui()

#-------------------------------------------------------------------------------

func _on_Battleground_begin_battle():
	_battleground.add_battle_camera(_camera)
	_guis.hide_ally_select_gui()

#-------------------------------------------------------------------------------

func _on_Battleground_current_battler_skills_acquired(skills):
	_guis.add_skills_to_list(skills)

#-------------------------------------------------------------------------------

func _on_Battleground_hide_active_gui_requested():
	_guis.hide_active_actor_gui()

#-------------------------------------------------------------------------------

func _on_Battleground_hide_target_gui_requested():
	_guis.hide_target_actor_gui()

#-------------------------------------------------------------------------------

func _on_Battleground_hide_weapon_gui_requested():
	_guis.hide_weapon_gui()

#-------------------------------------------------------------------------------

func _on_Battleground_load_active_actor_info(actor):
	_guis.load_active_actor_info(actor)

#-------------------------------------------------------------------------------

func _on_Battleground_load_target_actor_info(actor):
	_guis.load_target_actor_info(actor)

#-------------------------------------------------------------------------------

func _on_Battleground_player_battle_menu_requested(actor):
	_guis.show_player_battle_menu(actor)

#-------------------------------------------------------------------------------

func _on_Battleground_player_world_menu_requested(actor):
	_guis.show_player_world_menu(actor)

#-------------------------------------------------------------------------------

func _on_Battleground_selection_update_requested(type):
	_guis.update_squad_status(type)

#-------------------------------------------------------------------------------

func _on_Battleground_show_active_actor_gui_requested():
	_guis.show_active_actor_gui()

#-------------------------------------------------------------------------------

func _on_Battleground_show_target_actor_gui_requested():
	_guis.show_target_actor_gui()

#-------------------------------------------------------------------------------

func _on_Battleground_show_weapon_gui_requested(actor):
	_guis.load_weapon_gui(actor)

#-------------------------------------------------------------------------------

func _on_Battleground_squad_update_requested():
	_guis.update_squad_count()

#-------------------------------------------------------------------------------

func _on_Battleground_target_selected(target):
	_guis.load_target_actor_gui(target)

#-------------------------------------------------------------------------------

func _on_GUIs_player_waiting():
	_battleground.next_battler()

################################################################################
# DEBUG
################################################################################

func _provide_debug_info():
	# Cell vectors
	var label_info = []
	
	for location in _battleground.provide_used_cells('world'):
		var label_text = str(_battleground.world_to_map(location))
		label_info.append([location, label_text])
	
	_cell_vectors.configure_cell_labels(label_info)
