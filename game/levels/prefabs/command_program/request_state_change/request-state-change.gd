"""
Waypoint system that moves a designated character between each waypoint
specified by the user. Waypoints are designated by setting Position2D nodes
as children of this command program. 
"""
extends Node

var _manager = null
export (NodePath) var _entity_scene_path
var _entity = null
export (String, 'script_move') var _requested_state = 'script_move'

################################################################################
# PUBLIC METHODS
################################################################################

func end():
	var text = "%s has ended." % self.name
	CommandConsole.update_command_log(text)
	
	_entity.disconnect("state_changed", self, "_on_Entity_state_changed")
	_manager.next_program_in_queue()

#-------------------------------------------------------------------------------

func request_state_change():
	_entity.change_state_request(_requested_state)

#-------------------------------------------------------------------------------

func start(manager):
	var text = "%s has started." % self.name
	CommandConsole.update_command_log(text)
	
	_manager = manager
	_entity = get_node(_entity_scene_path)
	_entity.connect("state_changed", self, "_on_Entity_state_changed")
		
	request_state_change()

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_Entity_state_changed(state):
	end()
