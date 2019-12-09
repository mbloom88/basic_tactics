extends Node

var _manager = null
export (NodePath) var _camera_scene_path
var _camera = null
export (NodePath) var _actor_scene_path
var _actor = null
export (bool) var _untrack_actor

################################################################################
# PRIVATE METHODS
################################################################################

func _assign_new_tracking_target():
	_camera.track_actor(_actor)

#-------------------------------------------------------------------------------

func _untrack_actor():
	_camera.untrack_actor()

################################################################################
# PUBLIC METHODS
################################################################################

func end():
	var text = "%s has ended." % self.name
	CommandConsole.update_command_log(text)
	
	_camera.disconnect("tracking_added", self, "_on_Camera_tracking_added")
	_camera.disconnect("tracking_removed", self, "_on_Camera_tracking_removed")
	
	_manager.next_program_in_queue()

#-------------------------------------------------------------------------------

func start(manager):
	var text = "%s has started." % self.name
	CommandConsole.update_command_log(text)
	
	_manager = manager
	_camera = get_node(_camera_scene_path)
	_camera.connect("tracking_added", self, "_on_Camera_tracking_added")
	_camera.connect("tracking_removed", self, "_on_Camera_tracking_removed")
	
	if not _untrack_actor:
		_actor = get_node(_actor_scene_path)
		_assign_new_tracking_target()
	else:
		_untrack_actor()

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_Camera_tracking_added(actor):
	end()

#-------------------------------------------------------------------------------

func _on_Camera_tracking_removed(actor):
	end()
