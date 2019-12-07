extends "res://assets/scripts/state.gd"

################################################################################
# VIRTUAL METHODS
################################################################################

func _enter(host):
	if host._current_focus == null:
		host._current_focus = host._continue_button

	host._current_focus.grab_focus()
