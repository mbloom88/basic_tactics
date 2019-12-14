extends "res://assets/scripts/state.gd"

################################################################################
# VIRTUAL METHODS
################################################################################

func _enter(host):
	for button in get_tree().get_nodes_in_group('main_menu_buttons'):
		button.disabled = true
		button.focus_mode = Control.FOCUS_NONE
