"""
Base 'Battleground' scene.
"""
extends TileMap

# Signals
signal allies_ready_for_placement
signal battle_action_cancelled
signal battle_action_completed
signal begin_battle
signal current_battler_skills_acquired(skills)
signal current_weapon_update_requested(current_weapon)
signal hide_active_actor_gui_requested
signal hide_target_actor_gui_requested
signal hide_weapon_status_requested
signal load_active_actor_info(actor)
signal load_target_actor_info(actor)
signal load_weapon_info(weapon1, weapon2)
signal player_battle_menu_requested(actor)
signal player_world_menu_requested(actor)
signal refresh_weapon_info
signal selection_update_requested(type)
signal show_active_actor_gui_requested
signal show_target_actor_gui_requested
signal show_weapon_status_requested
signal squad_update_requested
signal state_changed(state)

# Child nodes
onready var _pathing = $Pathing
onready var _battle_positions = $AllyBattlePositions
onready var _blinking_cells = $BlinkingCells
onready var _battlers = $Battlers
onready var _non_battlers = $NonBattlers
onready var _objects = $Objects

# State machine
var _current_state = null
var _state_stack = []

onready var _state_map = {
	'idle': $State/Idle,
	'select': $State/Select,
	'place': $State/Place,
	'battle': $State/Battle,
}

# Tile info
export (float) var cell_offset_x = 0.50
export (float) var cell_offset_y = 0.25
export (PackedScene) var blinking_tile
var _used_map_cells = []
var _used_world_cells = []
var _map_size = Vector2()

# Actors
var _actors_on_grid = []
var _start_cells = {}
var _actor_to_place = null

# Battle parameters
var _allowed_move_cells = []
var _battle_camera = null

# AStar
export (PackedScene) var astar_instance

################################################################################
# VIRTUAL METHODS
################################################################################

func _process(delta):
	var state_name = _current_state._update(self, delta)
	
	if state_name:
		_change_state(state_name)

#-------------------------------------------------------------------------------

func _ready():
	_gather_cell_info()
	_determine_map_size()

	for actor in get_tree().get_nodes_in_group('actors'):
		update_actors_on_grid(actor, 'add')
	
	_state_stack.push_front($State/Idle)
	_current_state = _state_stack[0]
	_change_state('idle')

################################################################################
# PRIVATE METHODS
################################################################################

func _add_astar_instance(actor, goal_cell):
	var walkable_cells = []
	var actor_type = ActorDatabase.lookup_type(actor.reference)
	
	for map_cell in provide_used_cells('map'):
		var obstacle = _check_obstacle(map_cell)
		if obstacle:
			var obstacle_type = ActorDatabase.lookup_type(obstacle.reference)
			if actor_type == obstacle_type:
				walkable_cells.append(map_cell)
		else:
			walkable_cells.append(map_cell)
	
	var pathing_info = {
		'actor': actor,
		'actor_cell': world_to_map(actor.position),
		'goal_cell': goal_cell,
		'walkable_cells': walkable_cells,
	}
	
	var astar_node = astar_instance.instance()
	_pathing.add_child(astar_node)
	astar_node.connect('initialized', self, '_on_AStarInstance_initialized')
	astar_node.connect('pathing_completed', self, 
		'_on_AStarInstance_pathing_completed')
	astar_node.initialize(pathing_info)

#-------------------------------------------------------------------------------

func _add_blinking_cells(cells):
	"""
	Args: 
		- cells (Array): Vector2 map coordinates to place blinking tiles at.
	"""
	for cell in cells:
		var world_location = map_to_world(cell)
		var blinking_cell = blinking_tile.instance()
		
		blinking_cell.position = world_location
		_blinking_cells.add_child(blinking_cell)
		
	get_tree().call_group('blinking_tiles', 'blink')

#-------------------------------------------------------------------------------

func _change_state(state_name):
	if state_name != 'previous':
		if _state_map[state_name] != _current_state:
			_current_state._exit(self)

	if state_name == 'previous':
		_state_stack.pop_front()
	elif state_name == 'place':
		_state_stack.push_front(_state_map[state_name])
	else:
		var new_state = _state_map[state_name]
		_state_stack[0] = new_state

	_current_state = _state_stack[0]
	
	if state_name != 'previous':
		_current_state._enter(self)
	
	emit_signal("state_changed", state_name)

#-------------------------------------------------------------------------------

func _check_obstacle(cell):
	"""
	Checks for obstacles (actors, objects, etc.) in a target map cell.
	
	Args:
		- cell (Vector2): Map cell vector to check for an obstacle.
	
	Returns:
		- obstacle (Object): Actor that resides in the 'cell.' Returns as 'Null' 
			if there is no actor.
	"""
	var obstacle = null
	
	for actor in _actors_on_grid:
		if world_to_map(actor.position) == cell:
			obstacle = actor
	
	return obstacle

#-------------------------------------------------------------------------------

func _determine_map_size():
	var map_cells = provide_used_cells('map')
	var max_x = 0
	var max_y = 0
	
	for cell in map_cells:
		if cell.x > max_x:
			max_x = cell.x
	
	for cell in map_cells:
		if cell.y > max_y:
			max_y = cell.y
	
	_map_size = Vector2(max_x, max_y)

#-------------------------------------------------------------------------------

func _gather_cell_info():
	"""
	Creates a list of all the active tiles in the Battleground TileMap.
	"""
	_used_map_cells = get_used_cells()
	
	for map_cell in _used_map_cells:
		_used_world_cells.append(map_to_world(map_cell))

#-------------------------------------------------------------------------------

func _offset_world_position(map_cell):
	"""
	Converts a map cell to a world position with a positional offset.
	
	Args:
		- map_cell (Vector2): The map cell location within the TileMap.
	Returns:
		- world_position (Vector2): The new world position with an offset.
	"""
	var world_position = map_to_world(map_cell)
	world_position.x +=cell_size.x * cell_offset_x
	world_position.y +=cell_size.y * cell_offset_y
	
	return world_position

#-------------------------------------------------------------------------------

func _remove_blinking_cells():
	"""
	Removes all blinking tiles that are assigned to Battleground map cells.
	"""
	get_tree().call_group('blinking_tiles', 'stop_blinking')
	
	for tile in _blinking_cells.get_children():
		_blinking_cells.remove_child(tile)
		tile.queue_free()

################################################################################
# PUBLIC METHODS
################################################################################

func add_battle_camera(camera):
	"""
	Assigns the Level's camera to the Battleground.
	
	Args:
		- camera (Camera2D)
	"""
	_battle_camera = camera
	_battle_camera.connect('tracking_added', self, 
		'_on_BattleCamera_tracking_added')

#-------------------------------------------------------------------------------

func add_battler(actor):
	"""
	Adds an Actor to the Battleground as a battle combatant.
	
	Args:
		- actor_ref (Object)
	"""
	_battlers.add_child(actor)

#-------------------------------------------------------------------------------

func determine_move_path(actor, direction):
	"""
	Determines whether an Actor is allowed to move in the direction that was 
	requested.
	
	Args:
		- actor (Object): The actor that is requesting the move.
		- direction (Vector2): The direction the actor is trying to move in.
			The value must be expressed as a unit of 1 (e.g. Vector2(0, -1)) for
			proper execution.
	
	Returns:
		- world_position (Vector2): A world position that the actor is
			authorized to move into. Will return the actor's current position
			if the new position is outside of the allowable grid or if an 
			obstacle exists in that space.
	"""
	var new_world_position = actor.position
	var current_map_cell = world_to_map(new_world_position)
	var new_map_cell = current_map_cell + direction
	var obstacle = _check_obstacle(new_map_cell)
	
	if _current_state == _state_map['battle']:
		if new_map_cell in _allowed_move_cells:
			new_world_position = _offset_world_position(new_map_cell)
	else:
		if new_map_cell in _used_map_cells and not obstacle:
			new_world_position = _offset_world_position(new_map_cell)
	
	return new_world_position

#-------------------------------------------------------------------------------

func next_battler():
	"""
	Switches to the next Battler in the battle turn queue.
	"""
	if _current_state == _state_map['battle']:
		_current_state.setup_for_next_turn(self)

#-------------------------------------------------------------------------------

func place_actors():
	"""
	Activates the Ally selection and placement phase of a battle.
	"""
	if _current_state == _state_map['select']:
		_current_state.place_actors(self)

#-------------------------------------------------------------------------------

func provide_battlers():
	"""
	Returns a list of Battlers.
	"""
	return _battlers.get_children()

#-------------------------------------------------------------------------------

func provide_cell_size():
	return cell_size

#-------------------------------------------------------------------------------

func provide_current_battler_skills():
	if _current_state == _state_map['battle']:
		_current_state.provide_current_battler_skills(self)

#-------------------------------------------------------------------------------

func provide_used_cells(type):
	"""
	Provides the list of all active tiles in the Battleground TileMap either as
	world positions or map cells.
	
	Args:
		- type (String): The type of used cells to be requested.
			* map: Map cell vectors assigned to each tile. Primary use is
				within the TileMap.
			* world: World positions translated from the used map cells within
				the TileMap.
	"""
	match type:
		'map':
			return _used_map_cells
		'world':
			return _used_world_cells

#-------------------------------------------------------------------------------

func remove_battle_camera():
	"""
	Removes the Level's Camera from the Battleground.
	"""
	_battle_camera.disconnect('tracking_added', self,
		'_on_BattleCamera_tracking_added')
	_battle_camera = null

#-------------------------------------------------------------------------------

func remove_battler(actor):
	"""
	Removes the target Actor as a battle combatant.
	
	Args:
		- actor (Object)
	"""
	_battlers.remove_child(actor)
	actor.queue_free()

#-------------------------------------------------------------------------------

func find_player_attack_targets():
	"""
	Determines attack targets for the Battler whos turn it is.
	"""
	if _current_state == _state_map['battle']:
		_current_state.find_player_attack_targets(self, _battlers.get_children())

#-------------------------------------------------------------------------------

func start_battle():
	"""
	Starts a battle on the Battleground.
	"""
	for position2d in _battle_positions.get_children():
		var map_cell = world_to_map(position2d.position)
		_start_cells[position2d.name] = map_cell
	
	var map_cells = []
	for map_cell in _start_cells.values():
		map_cells.append(map_cell)
		
	_add_blinking_cells(map_cells)
	_change_state('select')

#-------------------------------------------------------------------------------

func update_actors_on_grid(actor, operation):
	"""
	Updates the list of registered Actors who can be manipulated within the 
	Battleground.
	
	Args:
		- actor (Object): The actor (character, object, etc.) to be updated.
		- operation (String): Whether the actor will be added or removed from
			the Array of actors.
				* add: Adds the actor to the Array.
				* remove: Removes the actor from the Array.
	"""
	match operation:
		'add':
			if not actor in _actors_on_grid:
				actor.connect('move_completed', self, 
					'_on_Actor_move_completed')
				actor.connect('move_requested', self, 
					'_on_Actor_move_requested')
				actor.connect('player_menu_requested', self, 
					'_on_Actor_player_menu_requested')
				actor.connect('reaction_completed', self, 
					'_on_Actor_reaction_completed')
				_actors_on_grid.append(actor)
		'remove':
			if actor in _actors_on_grid:
				actor.disconnect('move_completed', self, 
					'_on_Actor_move_completed')
				actor.disconnect('move_requested', self, 
					'_on_Actor_move_requested')
				actor.disconnect('player_menu_requested', self, 
					'_on_Actor_player_menu_requested')
				actor.disconnect('reaction_completed', self, 
					'_on_Actor_reaction_completed')
				_actors_on_grid.erase(actor)

#--------------------------------------------------------------------------------

func update_current_weapon():
	if _current_state == _state_map['battle']:
		_current_state.update_current_weapon()

#--------------------------------------------------------------------------------

func validate_skill_for_use(skill):
	if _current_state == _state_map['battle']:
		_current_state.validate_skill_for_use(self, skill)

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_Actor_move_completed(actor):
	var actor_type = ActorDatabase.lookup_type(actor.reference)
	# For AI movements during battle
	if _current_state == _state_map['battle'] and actor_type != 'ally':
		_current_state._on_Actor_move_completed(self, actor)

#-------------------------------------------------------------------------------

func _on_Actor_move_requested(actor, direction):
	var move_cell = determine_move_path(actor, direction)
	actor.perform_move(move_cell)

#-------------------------------------------------------------------------------

func _on_Actor_player_menu_requested(actor):
	if _current_state == _state_map['battle']:
		emit_signal('player_battle_menu_requested', actor)
	else:
		emit_signal('player_world_menu_requested', actor)

#-------------------------------------------------------------------------------

func _on_Actor_reaction_completed():
	if _current_state == _state_map['battle']:
		_current_state.setup_for_next_turn(self)

#-------------------------------------------------------------------------------

func _on_AStarInstance_initialized(astar_node):
	astar_node.calculate_astar_path()

#-------------------------------------------------------------------------------

func _on_AStarInstance_pathing_completed(astar_node, path, actor):
	astar_node.disconnect('initialized', self, '_on_AStarInstance_initialized')
	astar_node.disconnect('pathing_completed', self, 
		'_on_AStarInstance_pathing_completed')
	_pathing.remove_child(astar_node)
	astar_node.queue_free()
	
	if _current_state == _state_map['battle']:
		_current_state._on_AStarInstance_pathing_completed(self, path)

#-------------------------------------------------------------------------------

func _on_BattleCamera_tracking_added(actor):
	if _current_state == _state_map['battle']:
		_current_state._on_BattleCamera_tracking_added(self, actor)
