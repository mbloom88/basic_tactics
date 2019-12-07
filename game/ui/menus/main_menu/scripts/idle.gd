extends "res://assets/scripts/state.gd"

################################################################################
# VIRTUAL METHODS
################################################################################

func _enter(host):
	host._version.text = "Version %s" % Utils.game_version()
	
	for button in host._buttons.get_children():
		button.disabled = true
		button.focus_mode = Control.FOCUS_NONE
		
	if host._onready_activation:
		host._change_state('interact')

#-------------------------------------------------------------------------------

func _exit(host):
	for button in host._buttons.get_children():
		button.disabled = false
		button.focus_mode = Control.FOCUS_ALL
