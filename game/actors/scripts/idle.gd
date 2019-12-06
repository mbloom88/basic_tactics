extends "res://assets/state_scripts/state.gd"

var _action_keys = {
	'W': ['move_up', Vector2(0, -1)],
	'A': ['move_left', Vector2(-1, 0)],
	'S': ['move_down', Vector2(0, 1)],
	'D': ['move_right', Vector2(1, 0)],
	}

################################################################################
# VIRTUAL METHODS
################################################################################

func _enter(host):
	host.set_process_input(true)

#-------------------------------------------------------------------------------

func _handle_input(host, event):
	var action = event.as_text()
	
	if action in _action_keys.keys():
		
		if Input.is_action_just_pressed(_action_keys[action][0]):
			return 'move'
