extends "res://assets/scripts/state.gd"

################################################################################
# VIRTUAL METHODS
################################################################################

func _enter(host):
	yield(get_tree().create_timer(0.1), 'timeout') # slow down menu activation
	for button in get_tree().get_nodes_in_group('player_battle_menu_buttons'):
		button.disabled = false
		button.focus_mode = Control.FOCUS_ALL
	
	if host._current_focus == null:
		host._current_focus = host._attack_button

	host._current_focus.grab_focus()
	host.visible = true
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
	
	if Input.is_action_just_pressed("ui_cancel"):
		action = 'exit'
	
	return action
