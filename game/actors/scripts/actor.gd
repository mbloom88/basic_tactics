"""
Base 'Actor' scene.
"""
extends KinematicBody2D

# Signals 
signal camera_move_requested(location, move_speed)
signal move_completed
signal move_requested(actor, direction)
signal state_changed(state)

# Child nodes
onready var _tween_move = $TweenMove
onready var _state_label = $Debug/StateLabel

# State machine
var _current_state = null
var _state_stack = []

onready var _state_map = {
	'inactive': $State/Inactive,
	'idle': $State/Idle,
	'move': $State/Move,
}

# Actor info
export (String) var reference = ""
var script_running = false setget set_script_running, get_script_running

################################################################################
# VIRTUAL METHODS
################################################################################

func _input(event):
	var state_name = _current_state._handle_input(self, event)
	
	if state_name:
		_change_state(state_name)

#-------------------------------------------------------------------------------

func _process(delta):
	var state_name = _current_state._update(self, delta)
	
	if state_name:
		_change_state(state_name)

#-------------------------------------------------------------------------------

func _ready():
	_state_stack.push_front($State/Idle)
	_current_state = _state_stack[0]
	_change_state('inactive')

################################################################################
# PRIVATE METHODS
################################################################################

func _change_state(state_name):
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
	
	_state_label.update_label(_current_state.name)
	emit_signal("state_changed", state_name)

################################################################################
# PUBLIC METHODS
################################################################################

func activate():
	_change_state('idle')

#-------------------------------------------------------------------------------

func deactivate():
	_change_state('inactive')

#-------------------------------------------------------------------------------

func perform_move(cell):
	_current_state.move_to_cell(self, cell)

#-------------------------------------------------------------------------------

func perform_scripted_move(next_direction, movement_type):
	if not _current_state.has_method("determine_next_cell"):
		return
	
	_current_state.determine_next_cell(self, next_direction, movement_type)

#-------------------------------------------------------------------------------

func scripted_state_change(new_state):
	if new_state == 'inactive':
		script_running = false
	else:
		script_running = true
		
	_change_state(new_state)

################################################################################
# SETTERS
################################################################################

func set_script_running(value):
	script_running = value

################################################################################
# GETTERS
################################################################################

func get_script_running():
	return script_running

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_TweenMove_tween_completed(object, key):
	if not _current_state.has_method("_on_TweenMove_tween_completed"):
		return

	var state_name = _current_state._on_TweenMove_tween_completed(self, \
		object, key)
	
	if state_name:
		_change_state(state_name)
