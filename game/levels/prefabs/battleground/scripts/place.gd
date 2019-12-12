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
		if not host._check_obstacle(map_position):
			host.update_actors_on_grid(host._actor_to_place, 'add')
			action = 'previous'
	elif Input.is_action_just_pressed('ui_cancel'):
		host._actor_to_place.modulate_alpha_channel('out', 'instant')
		host._actor_to_place.position = Vector2(0, 0)
		action = 'previous'
	
	if direction:
		var world_position = host._actor_to_place.position
		var map_position = host.world_to_map(world_position)
		map_position += direction
		world_position = host.map_to_world(map_position)
		world_position.x += host.cell_size.x * 0.50
		world_position.y += host.cell_size.y * 0.25
		
		if world_position in host._start_cells.values():
			host._actor_to_place.position = world_position
	
	return action
