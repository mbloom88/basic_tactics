extends "res://assets/scripts/state.gd"

var _scene_focus = null

################################################################################
# PUBLIC METHODS
################################################################################

func _enter(host):
	host._prompt.focus_mode = Control.FOCUS_ALL
	
	# Determine which focus object to return focus to when exiting
	for node in get_tree().get_nodes_in_group("focus_objects"):
		if node.get_focus_owner():
			_scene_focus = node.get_focus_owner()
			break

	host._prompt.grab_focus()
	host._scroll_log_down()

#-------------------------------------------------------------------------------

func _exit(host):
	if _scene_focus:
		_scene_focus.grab_focus()
		_scene_focus = null

################################################################################

func _handle_input(host, event):
	if event is InputEventKey:
		if event.scancode == KEY_QUOTELEFT and not event.is_pressed():
			return 'deactivate'
		elif event.scancode == KEY_UP and not event.is_pressed():
			if host._pointer == null:
				return
			elif host._pointer == 0:
				host._pointer = (host._entry_history.size() - 1)
			else:
				host._pointer -= 1
			
			host._prompt.text = host._entry_history[host._pointer]
		elif event.scancode == KEY_DOWN and not event.is_pressed():
			if host._pointer == null:
				return
			elif host._pointer == host._entry_history.size() - 1:
				host._pointer = 0
			else:
				host._pointer += 1

			host._prompt.text = host._entry_history[host._pointer]
