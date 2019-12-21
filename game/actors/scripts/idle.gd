extends "res://assets/scripts/state.gd"

################################################################################
# VIRTUAL METHODS
################################################################################

func _enter(host):
	host.set_process(true)

#-------------------------------------------------------------------------------

func _update(host, delta):
	var action = check_user_inputs()
	if action:
		return action

################################################################################
# PUBLIC METHODS
################################################################################

func check_user_inputs():
	"""
	Looks for user inputs corresponding to specific actions.
	
	Returns:
		- action (String): The next action to be performance. Returns empty
			if no user input was detected.
	"""
	var action = ""
	
	if Input.is_action_just_pressed('ui_accept'):
		action = 'menu'
	elif Input.is_action_pressed("move_up"):
		action = 'move'
	elif Input.is_action_pressed("move_down"):
		action = 'move'
	elif Input.is_action_pressed("move_left"):
		action = 'move'
	elif Input.is_action_pressed("move_right"):
		action = 'move'
	
	return action
