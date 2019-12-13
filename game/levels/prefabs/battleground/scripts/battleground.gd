"""
Base 'Ground' scene.
"""
extends TileMap

# Signals
signal allies_ready_for_placement
signal ally_positions_requested
signal begin_battle
signal load_active_actor_info(actor_ref)
signal next_actor_in_turn
signal actor_turn_finished
signal player_battle_menu_requested(actor)
signal player_world_menu_requested(actor)
signal selection_update_requested(type)
signal squad_update_requested
signal state_changed(state)

# Child nodes
onready var _blinking_tiles = $BlinkingTiles
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
export (PackedScene) var blinking_tile
var _used_map_cells = []
var _used_world_cells = []

# Actors
var _actors_on_grid = []
var _start_cells = {}
var _actor_to_place = null

# Battle parameters
var _allowed_map_cells = []
var _battle_camera = null

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

	for actor in get_tree().get_nodes_in_group('actors'):
		update_actors_on_grid(actor, 'add')
	
	_state_stack.push_front($State/Idle)
	_current_state = _state_stack[0]
	_change_state('idle')

################################################################################
# PRIVATE METHODS
################################################################################

func _add_blinking_tiles(cells):
	"""
	Args: 
		- cells (Vector2): map coordinates
	"""
	for cell in cells:
		var world_location = map_to_world(cell)
		var blinking_cell = blinking_tile.instance()
		
		blinking_cell.position = world_location
		_blinking_tiles.add_child(blinking_cell)
		
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

func _gather_cell_info():
	_used_map_cells = get_used_cells()
	
	for map_cell in _used_map_cells:
		_used_world_cells.append(map_to_world(map_cell))

#-------------------------------------------------------------------------------

func _remove_blinking_tiles():
	get_tree().call_group('blinking_tiles', 'stop_blinking')
	
	for tile in _blinking_tiles.get_children():
		_blinking_tiles.remove_child(tile)
		tile.queue_free()

################################################################################
# PUBLIC METHODS
################################################################################

func add_battle_camera(camera):
	"""
	Args:
		- camera (Camera2D)
	"""
	_battle_camera = camera
	_battle_camera.connect('tracking_added', self, 
		'_on_BattleCamera_tracking_added')

#-------------------------------------------------------------------------------

func add_battler(actor):
	"""
	Args:
		- actor_ref (Object)
	"""
	_battlers.add_child(actor)

#-------------------------------------------------------------------------------

func determine_move_path(actor, direction):
	"""
	Args:
		- actor (Object): The actor that is requesting the move.
		- direction (Vector2): The direction the actor is trying to move in.
			The value must be expressed as a unit of 1 (e.g. Vector2(0, -1)) for
			proper execution.
	
	Returns:
		- new_world_cell (Vector2): An world (pixel) coordinate that the actor
			is authorized to move into. Will return the actor's current position
			if the new cell is outside of the allowable grid or if an obstacle
			exists in that space.
	"""
	var new_world_cell = actor.position
	var current_map_cell = world_to_map(actor.position)
	var new_map_cell = current_map_cell + direction
	var obstacle = _check_obstacle(new_map_cell)
	
	if _current_state == _state_map['battle']:
		if new_map_cell in _allowed_map_cells:
			new_world_cell = map_to_world(new_map_cell)
			new_world_cell.x += cell_size.x * 0.50
			new_world_cell.y += cell_size.y * 0.25
	else:
		if new_map_cell in _used_map_cells and not obstacle:
			new_world_cell = map_to_world(new_map_cell)
			new_world_cell.x += cell_size.x * 0.50
			new_world_cell.y += cell_size.y * 0.25
	
	return new_world_cell

#-------------------------------------------------------------------------------

func next_battler():
	emit_signal('actor_turn_finished')
	_remove_blinking_tiles()
	
	if not _current_state.has_method('setup_for_next_turn'):
		return
	
	_current_state.setup_for_next_turn(self)

#-------------------------------------------------------------------------------

func place_actors():
	if _current_state.has_method('place_actors'):
		_current_state.place_actors(self)

#-------------------------------------------------------------------------------

func provide_battlers():
	return _battlers.get_children()

#-------------------------------------------------------------------------------

func provide_cell_size():
	return cell_size

#-------------------------------------------------------------------------------

func provide_used_cells(type):
	"""
	Args:
		- type (String): The type of used cells to be requested.
			* map: Map cell vectors assigned to each tile. Primary use is
				within the TileMap.
			* world: World pixel coordinates translated from the used map cells
				within the TileMap.
	"""
	match type:
		'map':
			return _used_map_cells
		'world':
			return _used_world_cells

#-------------------------------------------------------------------------------

func register_battle_positions(world_cells):
	"""
	Args:
		- world_cells (Dictionary): Keys are the name of the world coordinates
			while values are the Vector2 world coordinate values. Note that one
			of the positions must be named 'Spawn'.
	"""
	_start_cells = world_cells
	var map_cells = []
	
	for world_cell in world_cells.values():
		map_cells.append(world_to_map(world_cell))
		
	_add_blinking_tiles(map_cells)
	_change_state('select')

#-------------------------------------------------------------------------------

func remove_battle_camera():
	_battle_camera.disconnect('tracking_added', self,
		'_on_BattleCamera_tracking_added')
	_battle_camera = null

#-------------------------------------------------------------------------------

func remove_battler(actor):
	"""
	Args:
		- actor (Object)
	"""
	_battlers.remove_child(actor)
	actor.queue_free()

#-------------------------------------------------------------------------------

func search_for_attack_targets():
	if _current_state == _state_map['battle']:
		_current_state.search_for_attack_targets(self, _battlers.get_children())

#-------------------------------------------------------------------------------

func start_battle():
	emit_signal('ally_positions_requested')

#-------------------------------------------------------------------------------

func update_actors_on_grid(actor, operation):
	"""
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
				actor.connect('move_requested', self, 
					'_on_Actor_move_requested')
				actor.connect('player_menu_requested', self, 
					'_on_Actor_player_menu_requested')
				actor.connect('enemy_ai_waiting', self, 
					'_on_Actor_enemy_ai_waiting')
				_actors_on_grid.append(actor)
		'remove':
			if actor in _actors_on_grid:
				actor.disconnect('move_requested', self, 
					'_on_Actor_move_requested')
				actor.disconnect('player_menu_requested', self, 
					'_on_Actor_player_menu_requested')
				actor.disconnect('enemy_ai_waiting', self, 
					'_on_Actor_enemy_ai_waiting')
				_actors_on_grid.erase(actor)

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_Actor_enemy_ai_waiting():
	next_battler()

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

func _on_BattleCamera_tracking_added(actor):
	if not _current_state.has_method('_on_BattleCamera_tracking_added'):
		return

	_current_state._on_BattleCamera_tracking_added(self, actor)
