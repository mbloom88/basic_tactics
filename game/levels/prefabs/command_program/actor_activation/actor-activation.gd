extends Node

var _manager = null
export (NodePath) var _actor_scene_path
export (bool) var _activate = true
var _actor = null

################################################################################
# PRIVATE METHODS
################################################################################

func _update_actor_activity_status():
	if _activate:
		_actor.activate()
	else:
		_actor.deactivate()
	
	end()

################################################################################
# PUBLIC METHODS
################################################################################

func end():
	var text = "%s has ended." % self.name
	CommandConsole.update_command_log(text)
	
	_manager.next_program_in_queue()

#-------------------------------------------------------------------------------

func start(manager):
	var text = "%s has started." % self.name
	CommandConsole.update_command_log(text)
	
	_manager = manager
	_actor = get_node(_actor_scene_path)
		
	_update_actor_activity_status()
