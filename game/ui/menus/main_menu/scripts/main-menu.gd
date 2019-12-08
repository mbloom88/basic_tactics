extends Control

# Signals 
signal new_game_requested
signal state_changed(menu, state)

# Child nodes 
onready var _buttons = $MenuButtons
onready var _continue_button = $MenuButtons/Continue
onready var _version = $GameVersion

# State machine
var _current_state = null
var _state_stack = []

onready var _state_map = {
	'idle': $State/Idle,
	'interact': $State/Interact,
	'exit': $State/Exit,
}

# Button handling
var _current_focus = null

# Independent scene editing
export (bool) var _onready_activation = false

################################################################################
# VIRTUAL METHODS
################################################################################

func _ready():
	_state_stack.push_front($State/Idle)
	_current_state = _state_stack[0]
	_change_state('idle')

################################################################################
# PRIVATE METHODS
################################################################################

func _change_state(state_name):
	if state_name != 'previous':
		if _state_map[state_name] != _current_state:
			_current_state._exit(self)

	if state_name == 'previous':
		_state_stack.pop_front()
	else:
		var new_state = _state_map[state_name]
		_state_stack[0] = new_state

	_current_state = _state_stack[0]
	
	if state_name != 'previous':
		_current_state._enter(self)
	
	emit_signal("state_changed", self, state_name)

################################################################################
# PUBLIC METHODS
################################################################################

func interact():
	_change_state('interact')

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_Continue_pressed():
	pass # Replace with function body.

#-------------------------------------------------------------------------------

func _on_Credits_pressed():
	pass # Replace with function body.

#-------------------------------------------------------------------------------

func _on_LoadGame_pressed():
	pass # Replace with function body.

#-------------------------------------------------------------------------------

func _on_NewGame_pressed():
	emit_signal("new_game_requested")
	_change_state('exit')

#-------------------------------------------------------------------------------

func _on_Options_pressed():
	pass # Replace with function body.

#-------------------------------------------------------------------------------

func _on_ExitGame_pressed():
	get_tree().quit()
