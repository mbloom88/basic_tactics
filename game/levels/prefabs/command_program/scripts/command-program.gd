extends Node

# Signals
signal command_program_completed

# Program content
export (bool) var _queue_free_on_completion = false
var _program_queue = []
var _current_program = null

################################################################################
# PUBLIC METHODS
################################################################################

func clear_program_info():
	_program_queue.clear()
	_current_program = null

#-------------------------------------------------------------------------------

func end_command_program():
	var text = "Command program '%s' complete. End of program queue. " % name
	CommandConsole.update_command_log(text)
	
	if _queue_free_on_completion:
		queue_free()
	
	emit_signal("command_program_completed")
	clear_program_info()

#-------------------------------------------------------------------------------

func initialize():
	CommandConsole.add_command_log_split()
	var text = "Command program '%s' has started." % name
	CommandConsole.update_command_log(text)
	
	for program in get_children():
		_program_queue.append(program)
	
	next_program_in_queue()

#-------------------------------------------------------------------------------

func interrupt_command_program(target_command_program):
	var text = "Command program '%s' interrupted." % name
	CommandConsole.update_command_log(text)
	text = "Executing command program '%s'." % target_command_program.name
	CommandConsole.update_command_log(text)
	
	target_command_program.initialize()
	clear_program_info()

#-------------------------------------------------------------------------------

func next_program_in_queue():
	if _program_queue.empty():
		end_command_program()
	else:
		_current_program = _program_queue.pop_front()
		_current_program.start(self)
