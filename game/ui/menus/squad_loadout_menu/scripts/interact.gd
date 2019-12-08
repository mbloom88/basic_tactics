extends "res://assets/scripts/state.gd"

################################################################################
# VIRTUAL METHODS
################################################################################

func _enter(host):
	host._squad_names.get_child(0).grab_focus()
	host.set_process(true)

#-------------------------------------------------------------------------------

func _update(host, delta):
	var action = _check_actions()
	
	if action:
		match action[0]:
			'exit':
				return 'exit'

################################################################################
# PRIVATE METHODS
################################################################################

func _check_actions():
	"""
	Looks for user inputs corresponding to specific actions.
	
	Returns:
		- action (Array): Two element array. Element 0 is the action to be
			performed. Element 1 is the value associated with that action. 
	"""
	var action = []
	
	if Input.is_action_just_pressed('player_menu') or \
		Input.is_action_just_pressed("ui_cancel"):
		action = ['exit', null]
	
	return action
