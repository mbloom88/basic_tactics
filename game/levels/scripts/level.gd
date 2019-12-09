"""
Base 'Level' scene.
"""
extends Node2D

# Signals 
signal player_menu_requested(actor)

# Child nodes
onready var _camera = $Camera
onready var _ground = $Ground
onready var _battlers = $Actors/Battlers
onready var _non_battlers = $Actors/NonBattlers
onready var _objects = $Actors/Objects
onready var _ally_positions = $AllyBattlePositions
onready var _battle_handler = $GUIs/BattleHandler
onready var _cell_vectors = $Debug/CellVectors
onready var _command = $CommandPrograms

################################################################################
# VIRTUAL METHODS
################################################################################

func _ready():
	_provide_debug_info()
	
	for battler in _battlers.get_children():
		battler.connect(
			"move_requested",
			self,
			"_on_Actor_move_requested")
		battler.connect(
			'player_menu_requested',
			self,
			'_on_Actor_player_menu_requested')
		_ground.update_actor_list(battler, 'add')
	
	for non_battler in _non_battlers.get_children():
		non_battler.connect(
			"move_requested",
			self,
			"_on_Actor_move_requested")
		non_battler.connect(
			'player_menu_requested',
			self,
			'_on_Actor_player_menu_requested')
		_ground.update_actor_list(non_battler, 'add')
	
	if _command.get_children():
		_command.get_child(0).initialize()

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_Actor_move_requested(actor, direction):
	var move_cell = _ground.determine_move_path(actor, direction)
	
	actor.perform_move(move_cell)

#-------------------------------------------------------------------------------

func _on_Actor_player_menu_requested(actor):
	emit_signal('player_menu_requested', actor)

#-------------------------------------------------------------------------------

func _on_BattleHandler_ally_positions_requested():
	var cells = []
	
	for cell in _ally_positions.get_children():
		cells.append(cell.position)
	
	_battle_handler.register_battle_positions(cells)

#-------------------------------------------------------------------------------

func _on_BattleHandler_blink_cells_requested(cells):
	_ground.blink_cells(cells)

################################################################################
# DEBUG
################################################################################

func _provide_debug_info():
	# Cell vectors
	var label_info = []
	
	for location in _ground.provide_used_cells('world'):
		var label_text = str(_ground.world_to_map(location))
		label_info.append([location, label_text])
	
	_cell_vectors.configure_cell_labels(label_info)
