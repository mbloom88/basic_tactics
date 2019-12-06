extends "res://assets/state_scripts/state.gd"

################################################################################
# VIRTUAL METHODS
################################################################################

func _enter(host):
	host.set_process(true)

#-------------------------------------------------------------------------------

func _update(host, delta):
	var action = check_actions()
	
	if action:
		return action[0]

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
