extends Control

# Signals 
signal state_changed(menu, state)

# Child nodes
onready var _buttons = $Background/HBoxContainer/MenuButtons
onready var _squad_button = $Background/HBoxContainer/MenuButtons/SquadLoadout
onready var _secondary = $Background/HBoxContainer/SecondaryPanels
onready var _squad = $Background/HBoxContainer/SecondaryPanels/SquadLoadoutPanel

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

#-------------------------------------------------------------------------------

func _process(delta):
	var state_name = _current_state._update(self, delta)
	
	if state_name:
		_change_state(state_name)

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

func hide_secondary_panels():
	for panel in _secondary.get_children():
		panel.visible = false

#-------------------------------------------------------------------------------

func interact():
	_change_state('interact')

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_ExitMenu_pressed():
	_change_state('exit')

#-------------------------------------------------------------------------------

func _on_SquadLoadout_pressed():
	hide_secondary_panels()
	_squad.activate()
