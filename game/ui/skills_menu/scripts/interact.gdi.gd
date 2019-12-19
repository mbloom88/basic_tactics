extends "res://assets/scripts/state.gd"

################################################################################
# VIRTUAL METHODS
################################################################################

func _enter(host):
	host.set_process(false)
	for skill_option in host._skill_list.get_children():
		skill_option.disconnect('skill_focus_entered', host, 
			'_on_SkillOption_skill_focus_entered')
		skill_option.disconnect('skill_selected', host, 
			'_on_SkillOption_skill_selected')
		host._skill_list.remove_child(skill_option)
		skill_option.queue_free()

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

################################################################################
# PUBLIC METHODS
################################################################################

func add_skills_to_list(host, skills):
	for skill in skills:
		var new_skill_option = host.skill_option_scene.instance()
		host._skill_list.add_child(new_skill_option)
		new_skill_option.update_skill_info(skill)
	
	for skill_option in host._skill_list.get_children():
		skill_option.connect('skill_focus_entered', host, 
			'_on_SkillOption_skill_focus_entered')
		skill_option.connect('skill_selected', host, 
			'_on_SkillOption_skill_selected')
	
	for skill_button in get_tree().get_nodes_in_group('skills_menu_buttons'):
		skill_button.disabled = false
		skill_button.focus_mode = Control.FOCUS_ALL
	
	if host._skill_list.get_child_count() > 0:
		if host._current_focus == null:
			var first_skill = \
				host._skill_list.get_child(0).provide_skill_button()
			host._current_focus = first_skill
		
		var skill_ref = host._skill_list.get_child(0).provide_skill_reference()
		host._description.bbcode_text = \
			'%s' % SkillsDatabase.lookup_description(skill_ref)
		host._current_focus.grab_focus()
		host.visible = true
	else:
		host._description.bbcode_text = ""
	
	host.set_process(true)
