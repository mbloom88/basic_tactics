extends Node

var _manager = null
export (NodePath) var _battle_handler_scene_path
var _battle_handler = null

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
	_battle_handler = get_node(_battle_handler_scene_path)	
	_battle_handler.start_battle()
	end()
