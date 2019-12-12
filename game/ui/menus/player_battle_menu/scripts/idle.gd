extends "res://assets/scripts/state.gd"

################################################################################
# VIRTUAL METHODS
################################################################################

func _enter(host):
	host.set_process(false)
	
	for button in host._buttons.get_children():
		button.disabled = true
		button.focus_mode = Control.FOCUS_NONE
