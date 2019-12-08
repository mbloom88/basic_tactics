"""
Base 'Level' scene.
"""
extends Node2D

# Signals 
signal player_menu_requested(actor)

# Child nodes
onready var _camera = $Camera
onready var _ground = $Ground
onready var _actors = $Actors
onready var _cell_vectors = $Debug/CellVectors
onready var _command = $CommandPrograms

################################################################################
# VIRTUAL METHODS
################################################################################

func _ready():
	_provide_debug_info()
	
	for actor in _actors.get_children():
		actor.connect(
			"move_requested",
			self,
			"_on_Actor_move_requested")
		actor.connect(
			'player_menu_requested',
			self,
			'_on_Actor_player_menu_requested')
		_ground.update_actor_list(actor, 'add')
	
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
