"""
Base 'Actor' scene.
"""
extends KinematicBody2D

# Signals 
signal camera_move_requested(location, move_speed)
signal move_completed
signal move_requested(actor, direction)
signal player_menu_requested(actor)
signal state_changed(state)

# Child nodes
onready var _job = $Job
onready var _inv = $Inventory
onready var _anim = $AnimationPlayer
onready var _tween_move = $TweenMove
onready var _state_label = $Debug/StateLabel

# State machine
var _current_state = null
var _state_stack = []

onready var _state_map = {
	'inactive': $State/Inactive,
	'idle': $State/Idle,
	'move': $State/Move,
	'menu': $State/Menu
}

# Actor info
export (String) var reference = "" setget , get_reference
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
	_state_stack.push_front($State/Inactive)
	_current_state = _state_stack[0]
	_change_state('inactive')

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
	
	_state_label.update_label(_current_state.name)
	emit_signal("state_changed", state_name)

################################################################################
# PUBLIC METHODS
################################################################################

func activate():
	"""
	Sets the Actor to the 'idle' state. Doing so enables Actor input processing.
	"""
	_change_state('idle')

#-------------------------------------------------------------------------------

func deactivate():
	"""
	Sets the Actor to the 'inactive' state. Doing so disables Actor input 
	processing.
	"""
	_change_state('inactive')

#-------------------------------------------------------------------------------

func fade_in():
	"""
	Fades the actor into the scene.
	"""
	_anim.play('fade-in')

#-------------------------------------------------------------------------------

func fade_out():
	"""
	Fades the actor out of the scene.
	"""
	_anim.play('fade-out')

#-------------------------------------------------------------------------------

func perform_move(cell):
	"""
	Move command that tells the Actor the next cell to move into. Generally 
	called from the 'Level/Ground' node after an Actor has made a move request
	based on user directional input.
	
	Args:
		- cell (Vector2): World cell for the actor to move into.
	"""
	_current_state.move_to_cell(self, cell)

#-------------------------------------------------------------------------------

func perform_scripted_move(next_direction, movement_type):
	"""
	Move command that tells the Actor the next direction to move into and 
	whether to walk or run in that direction. This function is generally called
	from a Command Program during cutscenes.
	"""
	if not _current_state.has_method("determine_next_cell"):
		return
	
	_current_state.determine_next_cell(self, next_direction, movement_type)

#-------------------------------------------------------------------------------

func resume_from_player_menu():
	"""
	Commands the Actor to resume processing after exiting from the Player Menu.
	"""
	_change_state('idle')

#-------------------------------------------------------------------------------

func scripted_state_change(new_state):
	"""
	Tells the Actor to change states. Generally called from a Command Program
	during cutscenes.
	
	Args:
		- new_state (String): The name of the state to change into.
	"""
	if new_state == 'inactive':
		script_running = false
	else:
		script_running = true
		
	_change_state(new_state)

#-------------------------------------------------------------------------------

func update_level(value):
	_job.level = value

################################################################################
# SETTERS
################################################################################

func set_script_running(value):
	script_running = value

################################################################################
# GETTERS
################################################################################

func get_reference():
	return reference

#-------------------------------------------------------------------------------

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
