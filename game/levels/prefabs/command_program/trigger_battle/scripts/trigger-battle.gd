extends Node

var _manager = null
export (NodePath) var _battleground_scene_path

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
	get_node(_battleground_scene_path).start_battle()
	end()
