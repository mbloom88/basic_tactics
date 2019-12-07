extends Node

var _manager = null
export (NodePath) var _dialogue_handler_scene_path
var _dialogue_handler = null
export (String, FILE, "*.json") var _json_file

################################################################################
# PUBLIC METHODS
################################################################################

func end():
	var text = "%s has ended." % self.name
	CommandConsole.update_command_log(text)
	
	_dialogue_handler.disconnect("dialogue_loaded", self, \
		"_on_DialogueHandler_dialogue_loaded")
	
	_manager.next_program_in_queue()
	
#-------------------------------------------------------------------------------

func start(manager):
	var text = "%s has started." % self.name
	CommandConsole.update_command_log(text)
	
	_manager = manager
	_dialogue_handler = get_node(_dialogue_handler_scene_path)
	_dialogue_handler.connect("dialogue_loaded", self, \
		"_on_DialogueHandler_dialogue_loaded")
	
	_dialogue_handler.load_dialogue(_json_file)
	
################################################################################
# SIGNAL HANDLING
################################################################################

func _on_DialogueHandler_dialogue_loaded():
	end()
