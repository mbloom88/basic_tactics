extends "res://assets/scripts/state.gd"

# Movement
export (float) var run_speed = 0.25
export (float) var walk_speed = 0.65
export (String, 'run', 'walk') var move_type = 'run'

################################################################################
# VIRTUAL METHODS
################################################################################

func _enter(host):
	if not host.script_running:
		host.set_process(true)
		move_type = 'run'

#-------------------------------------------------------------------------------

func _update(host, delta):
	var action = check_actions()
	
	if action:
		match action[0]:
			'move':
				host.set_process(false)
				host.emit_signal('move_requested', host, action[1])
	else:
		return 'idle'

################################################################################
# PUBLIC METHODS
################################################################################

func check_actions():
	"""
	Looks for user inputs corresponding to specific actions.
	
	Returns:
		- action (Array): Two element array. Element 0 is the action to be
			performed. Element 1 is the value associated with that action. 
	"""
	var action = []
	
	if Input.is_action_pressed("move_up"):
		action = ['move', Vector2(0, -1)]
	elif Input.is_action_pressed("move_down"):
		action = ['move', Vector2(0, 1)]
	elif Input.is_action_pressed("move_left"):
		action = ['move', Vector2(-1, 0)]
	elif Input.is_action_pressed("move_right"):
		action = ['move', Vector2(1, 0)]
	
	return action

#-------------------------------------------------------------------------------

func determine_next_cell(host, next_direction, movement_type):
	move_type = movement_type
	host.emit_signal('move_requested', host, next_direction)

#-------------------------------------------------------------------------------

func move_to_cell(host, cell):
	"""
	Moves the actor towards a cell corresponding with a move key.
	
	Args:
		- host (Object): The actor object for this state.
		- cell (Vector2): The next world cell to move into.
	"""
	if host.position != cell:
		var move_speed = 0.0
		
		match move_type:
			'run':
				move_speed = run_speed
			'walk':
				move_speed = walk_speed
		
		host._tween_move.interpolate_property(
			host,
			"position",
			host.position,
			cell,
			move_speed,
			Tween.TRANS_LINEAR,
			Tween.EASE_IN)
		
		host._tween_move.start()
		host.emit_signal('camera_move_requested', cell, move_speed)
	else:
		if not host.script_running:
			host.set_process(true)

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_TweenMove_tween_completed(host, object, key):
	if not host.script_running:
		host.set_process(true)
	
	host.emit_signal('move_completed', host)
