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
		var ally_to_remove = _active_allies[_ally_index]
		
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
		var ally_to_place = _active_allies[_ally_index]
		
		if squad_count < squad_limit:
			for location in host._start_cells.keys():
				if location == 'Spawn':
					spawn = host._start_cells['Spawn']
					break
					
			host._actor_to_place = ally_to_place
			ally_to_place.position = spawn
			ally_to_place.modulate_alpha_channel('in', 'instant')
			
			if ally_to_place in host._actors_on_grid:
				PartyDatabase.allies_in_squad -= 1
				host.emit_signal('squad_update_requested')
				host.update_actors_on_grid(ally_to_place, 'remove')
						
			action = 'place'
	
	elif Input.is_action_just_pressed('begin_battle'):
		host._remove_blinking_cells()
		
		for actor in _active_allies:
			if not actor in host._actors_on_grid:
				host.remove_battler(actor)
		
		action = 'battle'

	return action

#-------------------------------------------------------------------------------

func _check_if_selected(host):
	if _active_allies[_ally_index] in host._actors_on_grid:
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
	
	_max_index = len(ally_refs) - 1
	
	for ally_ref in ally_refs:
		var instantiated_ally = ActorDatabase.provide_actor_object(ally_ref)
		host.add_battler(instantiated_ally)
		_active_allies.append(instantiated_ally)

	host.emit_signal('allies_ready_for_placement')

################################################################################
# PUBLIC METHODS
################################################################################

func place_actors(host):
	host.emit_signal('load_active_actor_info', _active_allies[_ally_index])
	host.set_process(true)
