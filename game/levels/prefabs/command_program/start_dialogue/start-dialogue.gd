extends Node

var _manager = null
export (NodePath) var _dialogue_handler_scene_path
var _dialogue_handler = null

################################################################################
# PUBLIC METHODS
################################################################################

func end():
	var text = "%s has ended." % self.name
	CommandConsole.update_command_log(text)
	
	_dialogue_handler.disconnect("dialogue_finished", self, \
		"_on_DialogueHandler_dialogue_finished")
	
	_manager.next_program_in_queue()
	
#-------------------------------------------------------------------------------

func start(manager):
	var text = "%s has started." % self.name
	CommandConsole.update_command_log(text)
	
	_manager = manager
	_dialogue_handler = get_node(_dialogue_handler_scene_path)
	_dialogue_handler.connect("dialogue_finished", self, \
		"_on_DialogueHandler_dialogue_finished")
	
	_dialogue_handler.activate_dialogue()

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_DialogueHandler_dialogue_finished():
	end()
