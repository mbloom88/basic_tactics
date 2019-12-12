extends "res://assets/scripts/state.gd"

# Ally info
var _active_allies = []
var _ally_index = 0
var _max_index = 0

################################################################################
# VIRTUAL METHODS
################################################################################

func _enter(host):
	host.set_process(false)
	_instantiate_selectable_allies(host)

#-------------------------------------------------------------------------------

func _update(host, delta):
	_check_if_selected(host)
	
	var action = _check_actions(host)
		
	if action:
		return action

################################################################################
# PRIVATE METHODS
################################################################################

func _check_actions(host):
	"""
	Looks for user inputs corresponding to specific actions. 
	"""
	var action = ""
	
	if Input.is_action_just_pressed('ui_left'):
		if _ally_index == 0:
			_ally_index = _max_index
		else:
			_ally_index -= 1
		host.emit_signal('load_active_actor_info', _active_allies[_ally_index])
		
	elif Input.is_action_just_pressed("ui_right"):
		if _ally_index == _max_index:
			_ally_index = 0
		else:
			_ally_index += 1
		host.emit_signal('load_active_actor_info', _active_allies[_ally_index])
		
	elif Input.is_action_just_pressed('remove_squad_mate'):
		var ally_to_remove = null
		
		for actor in get_tree().get_nodes_in_group('actors'):
			if actor.reference == _active_allies[_ally_index]:
				ally_to_remove = actor
		
		if ally_to_remove in host._actors_on_grid:
			ally_to_remove.modulate_alpha_channel('out', 'instant')
			ally_to_remove.position = Vector2(0, 0)
			PartyDatabase.allies_in_squad -= 1
			host.emit_signal('squad_update_requested')
			host.update_actors_on_grid(ally_to_remove, 'remove')
			host._actor_to_place = null
	
	elif Input.is_action_just_pressed("ui_accept"):
		var spawn = Vector2()
		var squad_count = PartyDatabase.allies_in_squad
		var squad_limit = PartyDatabase.squad_limit
		
		if squad_count < squad_limit:
			for location in host._start_cells.keys():
				if location == 'Spawn':
					spawn = host._start_cells['Spawn']
					break
					
			for actor in get_tree().get_nodes_in_group('actors'):
				if actor.reference == _active_allies[_ally_index]:
					host._actor_to_place = actor
					actor.position = spawn
					actor.modulate_alpha_channel('in', 'instant')
					
					if actor in host._actors_on_grid:
						PartyDatabase.allies_in_squad -= 1
						host.emit_signal('squad_update_requested')
						host.update_actors_on_grid(actor, 'remove')
						
					break
			action = 'place'
	
	elif Input.is_action_just_pressed('begin_battle'):
		host._remove_blinking_tiles()
		
		for actor in get_tree().get_nodes_in_group('actors'):
			if not actor in host._actors_on_grid:
				host.remove_battler(actor)
		
		action = 'battle'

	return action

#-------------------------------------------------------------------------------

func _check_if_selected(host):
	var ally_to_check = null
	
	for actor in get_tree().get_nodes_in_group('actors'):
		if actor.reference == _active_allies[_ally_index]:
			ally_to_check = actor
	
	if ally_to_check in host._actors_on_grid:
		host.emit_signal('selection_update_requested', 'in_squad')
	else:
		host.emit_signal('selection_update_requested', 'not_selected')

#-------------------------------------------------------------------------------

func _instantiate_selectable_allies(host):
	var ally_refs = ActorDatabase.provide_unlocked_allies()
	
	for ally_ref in ally_refs:
		for actor in get_tree().get_nodes_in_group('actors'):
			if actor.reference == ally_ref:
				ally_refs.erase(actor.reference)
				PartyDatabase.allies_in_squad += 1
				host.emit_signal('squad_update_requested')
	
	_active_allies = ally_refs
	_max_index = len(_active_allies) - 1
	
	for ally_ref in _active_allies:
		host.add_battler(ally_ref)
	
	host.emit_signal('allies_ready_for_placement')

################################################################################
# PUBLIC METHODS
################################################################################

func place_actors(host):
	host.emit_signal('load_active_actor_info', _active_allies[0])
	host.emit_signal('selection_update_requested', 'not_selected')
	host.set_process(true)
