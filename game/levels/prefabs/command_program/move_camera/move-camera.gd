"""
Moves a camera in the level to a specified location. The location is established
by adding a Position2D node as a child of this command program node.
"""
extends Node

var _manager = null
export (NodePath) var _camera_scene_path
var _camera = null
export (float) var _move_speed = 1.0

################################################################################
# PUBLIC METHODS
################################################################################

func end():
	var text = "%s has ended." % self.name
	CommandConsole.update_command_log(text)
	
	_camera.disconnect("moved_to_location", self, \
		"_on_Camera_moved_to_location")
	
	_manager.next_program_in_queue()

#-------------------------------------------------------------------------------

func move_camera():
	_camera.move_to_location(get_child(0).position, _move_speed)

#-------------------------------------------------------------------------------

func start(manager):
	var text = "%s has started." % self.name
	CommandConsole.update_command_log(text)
	
	_manager = manager
	_camera = get_node(_camera_scene_path)
	_camera.connect( "moved_to_location", self, "_on_Camera_moved_to_location")
	
	move_camera()

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_Camera_moved_to_location():
	end()
