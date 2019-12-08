extends "res://assets/scripts/state.gd"

################################################################################
# VIRTUAL METHODS
################################################################################

func _enter(host):
	for button in host._buttons.get_children():
		button.disabled = false
		button.focus_mode = Control.FOCUS_ALL
	
	if host._current_focus == null:
		host._current_focus = host._continue_button

	host._current_focus.grab_focus()
