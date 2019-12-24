extends "res://assets/scripts/state.gd"

################################################################################
# VIRTUAL METHODS
################################################################################

func _enter(host):
	host.set_process(false)
	host.hide()
	
	for button in get_tree().get_nodes_in_group('skills_menu_buttons'):
		button.disabled = true
		button.focus_mode = Control.FOCUS_NONE
