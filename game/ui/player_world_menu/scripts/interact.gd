extends "res://assets/scripts/state.gd"

################################################################################
# VIRTUAL METHODS
################################################################################

func _enter(host):
	for button in host._buttons.get_children():
		button.disabled = false
		button.focus_mode = Control.FOCUS_ALL
	
	if host._current_focus == null:
		host._current_focus = host._buttons.get_children()[0]

	host._current_focus.grab_focus()
	host.set_process(true)

#-------------------------------------------------------------------------------

func _update(host, delta):
	var action = _check_actions()
	
	if action:
		return action

################################################################################
# PRIVATE METHODS
################################################################################

func _check_actions():
	var action = ""
	
	if Input.is_action_just_pressed('player_menu') or \
		Input.is_action_just_pressed("ui_cancel"):
		action = 'exit'
	
	return action