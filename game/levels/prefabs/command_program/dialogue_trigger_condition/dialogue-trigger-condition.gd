extends Node

var _manager = null
export (String) var _key = ""
export (String) var _value = ""
export (NodePath) var _event_command_program_scene_path
var _event_command_program = null

################################################################################
# PUBLIC METHODS
################################################################################

func check_dialogue_condition():
	var dialogue_exists = EventDatabase.lookup_dialogue(_key, _value)
	
	if dialogue_exists:
		_manager.interrupt_command_program(_event_command_program)
	else:
		end()

#-------------------------------------------------------------------------------

func end():
	var text = "%s has ended." % self.name
	CommandConsole.update_command_log(text)
	
	_manager.next_program_in_queue()
	
#-------------------------------------------------------------------------------

func start(manager):
	var text = "%s has started." % self.name
	CommandConsole.update_command_log(text)
	
	_manager = manager
	_event_command_program = get_node(_event_command_program_scene_path)
	
	check_dialogue_condition()
