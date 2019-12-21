extends "res://assets/scripts/state.gd"

# Placement info
var _spawn_cell = Vector2()

# Ally info
var _active_allies = []
var _index = 0
var _max_index = 0

################################################################################
# VIRTUAL METHODS
################################################################################

func _enter(host):
	host.set_process(false)
	_initialize(host)

#-------------------------------------------------------------------------------

func _update(host, delta):
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
		if _index == 0:
			_index = _max_index
		else:
			_index -= 1
		host.emit_signal('load_active_actor_info', _active_allies[_index])
		_check_if_selected(host)
	elif Input.is_action_just_pressed("ui_right"):
		if _index == _max_index:
			_index = 0
		else:
			_index += 1
		host.emit_signal('load_active_actor_info', _active_allies[_index])
		_check_if_selected(host)
	elif Input.is_action_just_pressed('ui_cancel'):
		var ally_to_remove = _active_allies[_index]
		if ally_to_remove in host._actors_on_grid:
			ally_to_remove.modulate_alpha_channel('out', 'instant')
			ally_to_remove.position = Vector2()
			PartyDatabase.allies_in_squad -= 1
			host.emit_signal('squad_update_requested')
			host.update_actors_on_grid(ally_to_remove, 'remove')
			host._actor_to_place = null
			_check_if_selected(host)
	elif Input.is_action_just_pressed("ui_accept"):
		var squad_count = PartyDatabase.allies_in_squad
		var squad_limit = PartyDatabase.squad_limit
		var ally_to_place = _active_allies[_index]
		if squad_count < squad_limit:
			host._actor_to_place = ally_to_place
			var spawn_point = host._offset_world_position(_spawn_cell)
			ally_to_place.position = spawn_point
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
	if _active_allies[_index] in host._actors_on_grid:
		host.emit_signal('selection_update_requested', 'in_squad')
	else:
		host.emit_signal('selection_update_requested', 'not_selected')

#-------------------------------------------------------------------------------

func _initialize(host):
	for location in host._start_cells.keys():
		if location == 'Spawn':
			_spawn_cell = host._start_cells['Spawn']
			break
	
	var ally_refs = ActorDatabase.provide_unlocked_allies()
	for actor in get_tree().get_nodes_in_group('actors'):
		if actor.reference in ally_refs:
			ally_refs.erase(actor.reference)
			PartyDatabase.allies_in_squad += 1
			host.emit_signal('squad_update_requested')
	
	_max_index = len(ally_refs) - 1
	
	for ally_ref in ally_refs:
		var instantiated_ally = ActorDatabase.provide_actor(ally_ref)
		host.add_battler(instantiated_ally)
		_active_allies.append(instantiated_ally)

	host.emit_signal('allies_ready_for_placement')

################################################################################
# PUBLIC METHODS
################################################################################

func place_actors(host):
	host.emit_signal('load_active_actor_info', _active_allies[_index])
	_check_if_selected(host)
	host.set_process(true)
