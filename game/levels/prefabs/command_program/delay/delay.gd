extends Node

# Child nodes
onready var _timer = $Timer

var _level = null
var _manager = null
export (float) var _delay = 1.0

################################################################################
# PRIVATE METHODS
################################################################################

func _configure_delay():
	_timer.wait_time = _delay
	_timer.start()

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
	
	_configure_delay()

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_Timer_timeout():
	end()
