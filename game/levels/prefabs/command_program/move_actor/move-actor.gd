"""
Moves a designated actor to a goal pointspecified by the user. Enable 'Editable
Children' in the right-click menu within the scene to be able to move the child
Position2D node to set the target position to move to.
"""
extends Node

# Child nodes
onready var _goal_position = $GoalPosition.position

# Scene info
var _manager = null
export (NodePath) var _actor_scene_path
var _actor = null
export (NodePath) var _battleground_scene_path
var _battleground = null
export (String, 'run', 'walk') var _movement_type = 'run'
export (bool) var _quickrun_next_program = false

################################################################################
# PRIVATE METHODS
################################################################################

func _trigger_astar_movement():
	var goal_cell = _battleground.world_to_map(_goal_position)
	_actor.perform_cutscene_move(goal_cell, _movement_type)

#-------------------------------------------------------------------------------

func _state_change_request():
	_actor.activate_for_cutscene('move')

################################################################################
# PUBLIC METHODS
################################################################################

func end():
	var text = '%s has ended.' % self.name
	CommandConsole.update_command_log(text)
	
	_actor.disconnect('cutscene_info_requested', self, \
		'_on_Actor_cutscene_info_requested')
	_actor.disconnect('cutscene_operation_completed', self, \
		'_on_Actor_cutscene_operation_completed')
	
	if not _quickrun_next_program:
		_manager.next_program_in_queue()

#-------------------------------------------------------------------------------

func start(manager):
	var text = '%s has started.' % self.name
	CommandConsole.update_command_log(text)
	
	_manager = manager
	_actor = get_node(_actor_scene_path)
	_actor.connect('cutscene_info_requested', self, \
		'_on_Actor_cutscene_info_requested')
	_actor.connect('cutscene_operation_completed', self, \
		'_on_Actor_cutscene_operation_completed')
	
	_battleground = get_node(_battleground_scene_path)
	
	if _quickrun_next_program:
		_manager.next_program_in_queue()
	
	_state_change_request()

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_Actor_cutscene_info_requested():
	_trigger_astar_movement()

#-------------------------------------------------------------------------------

func _on_Actor_cutscene_operation_completed():
	_actor.deactivate()
	end()
