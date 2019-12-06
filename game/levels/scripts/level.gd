"""
Level class.
"""
extends Node2D

onready var _ground = $Ground
onready var _actors = $Actors

################################################################################
# VIRTUAL METHODS
################################################################################

func _ready():
	for actor in _actors.get_children():
		actor.connect("move_requested", self, "_on_Actor_move_requested")
		_ground.update_actor_list(actor, 'add')

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_Actor_move_requested(actor, direction):
	var move_cell = _ground.determine_move_path(actor, direction)
	
	actor.perform_move(move_cell)
