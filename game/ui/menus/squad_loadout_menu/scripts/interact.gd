extends "res://assets/scripts/state.gd"

################################################################################
# VIRTUAL METHODS
################################################################################

func _enter(host):
	_configure_squadies(host)
	host.set_process(true)

#-------------------------------------------------------------------------------

func _update(host, delta):
	var action = _check_actions()
	
	if action:
		match action[0]:
			'exit':
				return 'exit'

################################################################################
# PRIVATE METHODS
################################################################################

func _check_actions():
	"""
	Looks for user inputs corresponding to specific actions.
	
	Returns:
		- action (Array): Two element array. Element 0 is the action to be
			performed. Element 1 is the value associated with that action. 
	"""
	var action = []
	
	if Input.is_action_just_pressed('player_menu') or \
		Input.is_action_just_pressed("ui_cancel"):
		action = ['exit', null]
	
	return action

#-------------------------------------------------------------------------------

func _configure_squadies(host):
	for squadie in host._squad_names.get_children():
		squadie.queue_free()
	
	var squad = PartyDatabase.provide_party()
	
	for squadie in squad.keys():
		if squad[squadie]['hired']:
			var new_button = host._squad_button.instance()
			var squadie_name = ActorDatabase.lookup_name(squadie)
			
			new_button.text = '%s "%s" %s' % [squadie_name[0], squadie_name[1],
				squadie_name[2]]
			new_button.update_actor_ref(squadie)
			host._squad_names.add_child(new_button)
			
			# Signal connections
			new_button.connect(
				'update_portrait',
				 host,
				'_on_Squadie_update_portrait')
			new_button.connect('just_toggled', host, '_on_Squadie_just_toggled')
			
			# Set "in squad" indicators
			if squad[squadie]['in_squad']:
				new_button.icon = host.green
			else:
				new_button.icon = host.red
	
	host._squad_names.get_child(0).grab_focus()
