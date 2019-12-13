"""
Base 'Actor' scene.
"""
extends KinematicBody2D

# Signals 
signal alpha_modulate_completed
signal camera_move_requested(location, move_speed)
signal move_completed
signal move_requested(actor, direction)
signal player_menu_requested(actor)
signal enemy_ai_waiting
signal state_changed(state)

# Child nodes
onready var _job = $Job
onready var _inventory = $Inventory
onready var _tween_alpha = $TweenAlpha
onready var _tween_move = $TweenMove
onready var _cursor = $BattleCursor
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
export (bool) var onready_invisible = true
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
	hide_battle_cursor()
	
	if onready_invisible:
		modulate_alpha_channel('out', 'instant')
	
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
	if ActorDatabase.lookup_type(reference) == 'enemy':
		yield(get_tree().create_timer(1), 'timeout')
		emit_signal('enemy_ai_waiting')
	else:
		_change_state('idle')

#-------------------------------------------------------------------------------

func deactivate():
	"""
	Sets the Actor to the 'inactive' state. Doing so disables Actor input 
	processing.
	"""
	_change_state('inactive')

#-------------------------------------------------------------------------------

func hide_battle_cursor():
	_cursor.visible = false

#-------------------------------------------------------------------------------

func modulate_alpha_channel(fade_type, mode, speed=0.5):
	"""
	Args:
		- fade_type (String): The type of scene fade that the character will
			perform.
			* in: Character will fade into the scene.
			* out: Character will fade out of the scene.
		- mode (String): Determines whether the character will fade instantly
			of over time.
			* instant: Character fades instantly.
			* slow: Character fades slowly over a set duration.
		- speed (float): The speed at which the character fades into/from the
			scene. Ignored if mode is set to 'instant.'
	"""
	var start_alpha = modulate
	var end_alpha = modulate
	
	match [fade_type, mode]:
		['in', 'instant']:
			modulate.a = 1
			emit_signal("alpha_modulate_completed")
			return
		['out', 'instant']:
			modulate.a = 0
			emit_signal("alpha_modulate_completed")
			return
		['in', 'slow']:
			start_alpha.a = 0
			end_alpha.a = 1
		['out', 'slow']:
			start_alpha.a = 1
			end_alpha.a = 0
	
	_tween_alpha.interpolate_property(
		self,
		"modulate",
		start_alpha,
		end_alpha,
		speed,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN)
	
	_tween_alpha.start()

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

func provide_job_info():
	return _job.provide_job_info()

#-------------------------------------------------------------------------------

func provide_weapon():
	return _inventory.provide_weapon()

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

func show_battle_cursor():
	_cursor.visible = true

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

#-------------------------------------------------------------------------------

func _on_TweenAlpha_tween_completed(object, key):
	emit_signal("alpha_modulate_completed")
