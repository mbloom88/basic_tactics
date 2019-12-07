extends Node

var _manager = null
export (String) var _debug_text = ""

################################################################################
# PUBLIC METHODS
################################################################################

func debug_and_test():
	if _debug_text:
		print(_debug_text)
	
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
	debug_and_test()
