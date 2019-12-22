extends Control

# Signals 
signal menu_requested(menu)
signal player_browsing_skills
signal player_waiting
signal state_changed(menu, state)

# Child nodes
onready var _attack_button = $Background/MenuButtons/Attack

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

# Actor info
var _current_actor = null

################################################################################
# VIRTUAL METHODS
################################################################################

func _process(delta):
	var state_name = _current_state._update(self, delta)
	
	if state_name:
		_change_state(state_name)

#-------------------------------------------------------------------------------

func _ready():
	_state_stack.push_front($State/Idle)
	_current_state = _state_stack[0]
	_change_state('interact')

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

func exit():
	_change_state('exit')

#-------------------------------------------------------------------------------

func interact():
	_change_state('interact')

#-------------------------------------------------------------------------------

func set_actor(actor):
	_current_actor = actor

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_Attack_pressed():
	_current_actor.initiate_attack()
	_change_state('idle')

#-------------------------------------------------------------------------------

func _on_Skills_pressed():
	emit_signal('player_browsing_skills')
	_change_state('idle')

#-------------------------------------------------------------------------------

func _on_Wait_pressed():
	emit_signal('player_waiting')
	_change_state('exit')
