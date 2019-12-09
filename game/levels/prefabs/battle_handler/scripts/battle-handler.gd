extends Control

# Signals
signal ally_positions_requested()
signal blink_cells_requested(cells)
signal state_changed(state)

# State machine
var _current_state = null
var _state_stack = []

onready var _state_map = {
	'idle': $State/Idle,
	'move_actors': $State/MoveActors,
}

# Ally info
var _active_allies = []

# Battlefield
var _start_cells = []

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
	
	emit_signal("state_changed", state_name)

################################################################################
# PUBLIC METHODS
################################################################################

func register_battle_positions(positions):
	_start_cells = positions
	emit_signal('blink_cells_requested', _start_cells)
	_change_state('move_actors')

#-------------------------------------------------------------------------------

func start_battle():
	emit_signal('ally_positions_requested')
