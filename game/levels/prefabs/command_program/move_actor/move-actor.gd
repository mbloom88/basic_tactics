"""
Waypoint system that moves a designated actor between each waypoint
specified by the user. Waypoints are designated by setting Position2D nodes
as children of this command program. 
"""
extends Node

var _manager = null
export (NodePath) var _actor_scene_path
var _actor = null
export (String, 'run', 'walk') var _movement_type = 'run'
export (bool) var _quickrun_next_program = false
var _move_path = []

################################################################################
# PRIVATE METHODS
################################################################################

func _determine_path():
	var current_position = _actor.position
	
	var text = 'Calculating moves...'
	CommandConsole.update_command_log(text)
	
	for waypoint in get_children():
		var x = int(sign(waypoint.position.x - current_position.x))
		var y = int(sign(waypoint.position.y - current_position.y))
		var direction = Vector2(x, y)
		
		_move_path.append(direction)
		
		text = '%s %s: %s >>> %s' % [
			_actor.name, _movement_type, current_position, waypoint.position]
		CommandConsole.update_command_log(text)
		
		current_position = waypoint.position
	
	_move_request()

#-------------------------------------------------------------------------------

func _move_request():
	
	var next_direction = _move_path.pop_front()
	var text = 'Moving %s in %s direction.' % [_actor.name, next_direction]
	CommandConsole.update_command_log(text)
	_actor.perform_scripted_move(next_direction, _movement_type)

#-------------------------------------------------------------------------------

func _state_change_request():
	_actor.scripted_state_change('move')

################################################################################
# PUBLIC METHODS
################################################################################

func end():
	var text = '%s has ended.' % self.name
	CommandConsole.update_command_log(text)
	
	_actor.disconnect("move_completed", self, '_on_Actor_move_completed')
	_actor.disconnect('state_changed', self, '_on_Actor_state_changed')
	
	if not _quickrun_next_program:
		_manager.next_program_in_queue()

#-------------------------------------------------------------------------------

func start(manager):
	var text = '%s has started.' % self.name
	CommandConsole.update_command_log(text)
	
	_manager = manager
	_actor = get_node(_actor_scene_path)
	_actor.connect('move_completed', self, '_on_Actor_move_completed')
	_actor.connect('state_changed', self, '_on_Actor_state_changed')
	
	if _quickrun_next_program:
		_manager.next_program_in_queue()
	
	_state_change_request()

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_Actor_move_completed():
	if _move_path:
		_move_request()
	else:
		_actor.scripted_state_change('inactive')
		end()

#-------------------------------------------------------------------------------

func _on_Actor_state_changed(state):
	if state == 'move':
		_determine_path()
	