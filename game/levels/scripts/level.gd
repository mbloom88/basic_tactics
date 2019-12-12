"""
Base 'Level' scene.
"""
extends Node2D

# Signals 
signal player_menu_requested(actor)

# Child nodes
onready var _camera = $Camera
onready var _battleground = $Battleground
onready var _ally_positions = $AllyBattlePositions
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

func _on_Battleground_allies_ready_for_placement():
	_battle_gui.show_ally_select_gui()
	_battleground.place_actors()

#-------------------------------------------------------------------------------

func _on_Battleground_ally_positions_requested():
	var start_cells = {}
	
	for cell in _ally_positions.get_children():
		start_cells[cell.name] = cell.position
	
	_battleground.register_battle_positions(start_cells)

#-------------------------------------------------------------------------------

func _on_Battleground_load_active_actor_info(actor_ref):
	_battle_gui.load_actor_info(actor_ref)

#-------------------------------------------------------------------------------

func _on_Battleground_player_menu_requested(actor):
	emit_signal("player_menu_requested", actor)

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
