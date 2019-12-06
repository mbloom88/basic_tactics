extends "res://assets/state_scripts/state.gd"

################################################################################
# PUBLIC METHODS
################################################################################

func _enter(host):
	get_tree().paused = false
	host._console.visible = false
	host._prompt.focus_mode = Control.FOCUS_NONE
	host._prompt.clear()

#-------------------------------------------------------------------------------

func _exit(host):
	get_tree().paused = true
	host._console.visible = true

#-------------------------------------------------------------------------------

func _handle_input(host, event):
	if event is InputEventKey:
		if event.scancode == KEY_QUOTELEFT and not event.is_pressed():
			return 'activate'
