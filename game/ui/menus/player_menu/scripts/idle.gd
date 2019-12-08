extends "res://assets/scripts/state.gd"

################################################################################
# VIRTUAL METHODS
################################################################################

func _enter(host):
	for button in host._buttons.get_children():
		button.disabled = true
		button.focus_mode = Control.FOCUS_NONE
	
	if host._onready_activation:
		host._change_state('interact')
