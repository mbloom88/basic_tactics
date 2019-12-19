extends "res://assets/scripts/state.gd"

################################################################################
# VIRTUAL METHODS
################################################################################

func _enter(host):
#	for skill_button in host._skill_list.get_children():
#		skill_button.disconnect('focus_entered', host, 
#			'_on_SkillOption_focus_entered')
#		host._skill_list.remove(skill_button)
#		skill_button.queue_free()
	
		# Need to instantiate skill_option nodes and then connect them up.
	
	for skill_option in host._skill_list.get_children():
		skill_option.connect('skill_focus_entered', host, 
			'_on_SkillOption_skill_focus_entered')
	
	for skill_button in get_tree().get_nodes_in_group('skills_menu_buttons'):
		skill_button.disabled = false
		skill_button.focus_mode = Control.FOCUS_ALL
	
	if host._current_focus == null:
		var first_skill = host._skill_list.get_child(0).provide_skill_button()
		host._current_focus = first_skill

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
	
	if Input.is_action_just_pressed('player_menu') or \
		Input.is_action_just_pressed("ui_cancel"):
		action = 'exit'
	
	return action
