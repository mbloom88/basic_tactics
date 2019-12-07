extends Node

var _manager = null
export (bool) var _queue_free_on_completion = false
export (String) var _key = ""
export (String) var _key2 = ""
export ( \
	String, \
	'boolean', \
	'integer', \
	'whole_array', \
	'value_in_array') var _condition = 'boolean'
export (bool) var boolean = false
export (Array) var whole_array = []
export (Array) var value_in_array = []
export (NodePath) var _event_command_program_scene_path
var _event_command_program = null

################################################################################
# PUBLIC METHODS
################################################################################

func check_event_condition():
	var event_value = EventDatabase.lookup_event_value(_key, _key2)
	var event_flag = false
	
	match _condition:
		'boolean':
			if event_value == boolean:
				event_flag = true
	
	if event_flag:
		_manager.interrupt_command_program(_event_command_program)
		
		if _queue_free_on_completion:
			queue_free()
		
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
	
	check_event_condition()
