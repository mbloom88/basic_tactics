extends "res://assets/state_scripts/state.gd"

var _action_keys = {
	'W': ['move_up', Vector2(0, -1)],
	'A': ['move_left', Vector2(-1, 0)],
	'S': ['move_down', Vector2(0, 1)],
	'D': ['move_right', Vector2(1, 0)],
	}

export (float) var move_speed = 0.25

################################################################################
# VIRTUAL METHODS
################################################################################

func _enter(host):
	host.set_process_input(true)

#-------------------------------------------------------------------------------

func _handle_input(host, event):
	var action = event.as_text()
	
	if action in _action_keys.keys():
		
		if Input.is_action_pressed(_action_keys[action][0]):
			host.set_process_input(false)
			host.emit_signal('move_requested', host, _action_keys[action][1])
			print('Move requested: %s' % _action_keys[action][1])
			
		elif Input.is_action_just_released(_action_keys[action][0]):
			return 'idle'

################################################################################
# PUBLIC METHODS
################################################################################

func move_to_cell(host, cell):
	if host.position != cell:
		host.position = cell
		yield(get_tree().create_timer(move_speed), "timeout")
	
	host.set_process_input(true)
