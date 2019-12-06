"""
Global command console for the game. 

WARNING: Running this script independently with F6 has undesirable effects.
Recommended to run this script inside a test scenee.
"""
extends CanvasLayer

# Child nodes
onready var _console = $ConsolePanel
onready var _scroll = $ConsolePanel/VBoxContainer/ScrollContainer
onready var _command_log = \
	$ConsolePanel/VBoxContainer/ScrollContainer/CommandLog
onready var _prompt = $ConsolePanel/VBoxContainer/Prompt

# State machine
var _current_state = null
var _states_stack = []

onready var _states_map = {
	'deactivate': $States/Deactivate,
	'activate': $States/Activate,
}

# Prompt entry 
var _entry_history = []
var _pointer = null

################################################################################
# VIRTUAL METHODS
################################################################################

func _change_state(state_name) -> void:
	_current_state._exit(self)
	
	if state_name == 'previous':
		_states_stack.pop_front()
	else:
		var new_state = _states_map[state_name]
		_states_stack[0] = new_state

	_current_state = _states_stack[0]

	if state_name != 'previous':
		_current_state._enter(self)

#-------------------------------------------------------------------------------

func _initialize_command_prompt():
	var text = "%s v%s" % [Utils.game_name(), Utils.game_version()]
	update_command_log(text)
	text = "Godot v%s" % Utils.godot_version()
	update_command_log(text)
	add_command_log_split()

#-------------------------------------------------------------------------------

func _input(event):
	var state_name = _current_state._handle_input(self, event)
	
	if state_name:
		_change_state(state_name)

#-------------------------------------------------------------------------------

func _ready():
	_initialize_command_prompt()
	_states_stack.push_front($States/Deactivate)
	_current_state = _states_stack[0]
	_change_state('deactivate')

#-------------------------------------------------------------------------------

func _scroll_log_down():
	yield(get_tree().create_timer(0.005), "timeout")
	var vscroll_max = _scroll.get_v_scrollbar().max_value
	_scroll.scroll_vertical = vscroll_max

################################################################################
# PUBLIC METHODS
################################################################################

func add_command_log_split():
	var current_history = _command_log.text
	var split = "--------------------------------------------------"
	_command_log.text = current_history + "\n" + split

#-------------------------------------------------------------------------------

func update_command_log(log_text):
	var current_history = _command_log.text
	var datetime = Utils.datetime()
	var new_log_text = datetime + ": " + log_text 
	_command_log.text = current_history + "\n" + new_log_text

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_Prompt_text_changed(new_text):
	if new_text == "`":
		_prompt.clear()

#-------------------------------------------------------------------------------

func _on_Prompt_text_entered(new_text):
	"""
	Takes text that is entered into the command prompt to determine the 
	appropriate global command.
	
	# Args
		- new_text (str): text entered by the user.
	"""
	_entry_history.append(new_text)
	_pointer = _entry_history.size() - 1
	var current_history = _command_log.text
	var command = new_text.split(" ")
	var fields = command.size()
	var datetime = Utils.datetime()
	var new_log_text = datetime + ": " + "Invalid command received."
	
	match command[0]:
		'debug_mode':
			match command[1]:
				'activate':
					get_tree().call_group("debug", "activate")
					new_log_text = datetime + ": " + "Debug mode activated."
				'deactivate':
					get_tree().call_group("debug", "deactivate")
					new_log_text = datetime + ": " + "Debug mode deactivated."
		
	_command_log.text = current_history + "\n" + new_log_text
	_prompt.clear()
	_scroll_log_down()
