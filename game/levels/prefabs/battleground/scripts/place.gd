extends "res://assets/scripts/state.gd"

var _obstructed = false

################################################################################
# VIRTUAL METHODS
################################################################################

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
	var direction = Vector2()
	
	if Input.is_action_just_pressed('ui_up'):
		direction = Vector2(0, -1)
	elif Input.is_action_just_pressed('ui_down'):
		direction = Vector2(0, 1)
	elif Input.is_action_just_pressed('ui_left'):
		direction = Vector2(-1, 0)
	elif Input.is_action_just_pressed("ui_right"):
		direction = Vector2(1, 0)
	elif Input.is_action_just_pressed("ui_accept"):
		var map_position = host.world_to_map(host._actor_to_place.position)
		var obstacle = host._check_obstacle(map_position)
		if not obstacle:
			host.update_actors_on_grid(host._actor_to_place, 'add')
			PartyDatabase.allies_in_squad += 1
			host.emit_signal('squad_update_requested')
			host.emit_signal('selection_update_requested', 'in_squad')
			action = 'previous'
	elif Input.is_action_just_pressed('ui_cancel'):
		host._actor_to_place.modulate_alpha_channel('out', 'instant')
		host._actor_to_place.position = Vector2()
		if host._actor_to_place in host._actors_on_grid:
			PartyDatabase.allies_in_squad -= 1
			host.emit_signal('squad_update_requested')
			host.update_actors_on_grid(host._actor_to_place, 'remove')
			host._actor_to_place = null
			host.emit_signal('selection_update_requested', 'not_selected')
		action = 'previous'
	
	# If movement direction, move the actor
	if direction:
		var world_position = host._actor_to_place.position
		var map_position = host.world_to_map(world_position)
		map_position += direction
		
		if map_position in host._start_cells.values():
			world_position = host.offset_world_position(map_position)
			host._actor_to_place.position = world_position
	
	return action
