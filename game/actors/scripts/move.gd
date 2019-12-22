extends "res://assets/scripts/state.gd"

# Movement
export (float) var run_speed = 0.25
export (float) var walk_speed = 0.65
export (String, 'run', 'walk') var move_type = 'run'

################################################################################
# VIRTUAL METHODS
################################################################################

func _enter(host):
	if not host.has_script_running and not host.has_ai_running:
		host.set_process(true)
		move_type = 'run'
	elif host.has_ai_running:
		_perform_next_ai_movement(host)

#-------------------------------------------------------------------------------

func _update(host, delta):
	var direction = check_move_directions()
	if direction:
		host.set_process(false)
		host.emit_signal('move_requested', host, direction)
	else:
		return 'previous'

################################################################################
# PRIVATE METHODS
################################################################################

func _perform_next_ai_movement(host):
	move_type = 'run'
	var next_direction = host._ai_movements.pop_front()
	host.emit_signal('move_requested', host, next_direction)

################################################################################
# PUBLIC METHODS
################################################################################

func check_move_directions():
	"""
	Looks for user inputs corresponding to specific move directions.
	
	Returns:
		- direction (Vector2): The next direction to move in. Returns Vector2()
			if no user input was detected.
	"""
	var direction = Vector2()
	
	if Input.is_action_pressed("move_up"):
		direction = Vector2(0, -1)
	elif Input.is_action_pressed("move_down"):
		direction = Vector2(0, 1)
	elif Input.is_action_pressed("move_left"):
		direction = Vector2(-1, 0)
	elif Input.is_action_pressed("move_right"):
		direction = Vector2(1, 0)
	
	return direction

#-------------------------------------------------------------------------------

func determine_next_cell(host, next_direction, movement_type):
	"""
	Used to move the actor during cutscenes.
	"""
	move_type = movement_type
	host.emit_signal('move_requested', host, next_direction)

#-------------------------------------------------------------------------------

func move_to_position(host, world_position):
	"""
	Moves the actor towards a cell corresponding with a move key.
	
	Args:
		- host (Object): The actor object for this state.
		- cell (Vector2): The next world cell to move into.
	"""
	if host.position != world_position:
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
			world_position,
			move_speed,
			Tween.TRANS_LINEAR,
			Tween.EASE_IN)
		
		host._tween_move.start()
		host.emit_signal('camera_move_requested', world_position, move_speed)
	else:
		if not host.has_script_running and not host.has_ai_running:
			host.set_process(true)

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_TweenMove_tween_completed(host, object, key):
	if host.has_script_running:
		host.emit_signal('move_completed', host)
	elif host.has_ai_running:
		if not host._ai_movements.empty():
			_perform_next_ai_movement(host)
		else:
			return 'previous'
	else:
		host.set_process(true)
