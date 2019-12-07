extends Node

var _manager = null
export (NodePath) var _camera_scene_path
var _camera = null
export (NodePath) var _actor_scene_path
var _actor = null

################################################################################
# PRIVATE METHODS
################################################################################

func _assign_new_tracking_target():
	_camera.track_actor(_actor)

################################################################################
# PUBLIC METHODS
################################################################################

func end():
	var text = "%s has ended." % self.name
	CommandConsole.update_command_log(text)
	
	_camera.disconnect("tracking_added", self, "_on_Camera_tracking_added")
	
	_manager.next_program_in_queue()

#-------------------------------------------------------------------------------

func start(manager):
	var text = "%s has started." % self.name
	CommandConsole.update_command_log(text)
	
	_manager = manager
	_camera = get_node(_camera_scene_path)
	_camera.connect("tracking_added", self, "_on_Camera_tracking_added")
	_actor = get_node(_actor_scene_path)
	
	_assign_new_tracking_target()

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_Camera_tracking_added(actor):
	end()
