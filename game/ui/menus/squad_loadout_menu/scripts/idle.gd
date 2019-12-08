extends "res://assets/scripts/state.gd"

################################################################################
# VIRTUAL METHODS
################################################################################

func _enter(host):
	host.set_process(false)
	_configure_squadies(host)

################################################################################
# PRIVATE METHODS
################################################################################

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
