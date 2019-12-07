"""
Base 'Ground' scene.
"""
extends TileMap

# Tile info
var _used_map_cells = []
var _used_world_cells = []

# Actors
var _actor_list = []

################################################################################
# VIRTUAL METHODS
################################################################################

func _ready():
	_gather_cell_info()

################################################################################
# PRIVATE METHODS
################################################################################

func _check_obstacle(cell):
	"""
	Args:
		- cell (Vector2): Map cell vector to check for an obstacle.
	
	Returns:
		- obstacle (Object): Actor that resides in the 'cell.' Returns as 'Null' 
			if there is no actor.
	"""
	var obstacle = null
	
	for actor in _actor_list:
		if world_to_map(actor.position) == cell:
			obstacle = actor
	
	return obstacle

#-------------------------------------------------------------------------------

func _gather_cell_info():
	_used_map_cells = get_used_cells()
	
	for map_cell in _used_map_cells:
		_used_world_cells.append(map_to_world(map_cell))

################################################################################
# PUBLIC METHODS
################################################################################

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
		
	if new_map_cell in _used_map_cells and not obstacle:
		new_world_cell = map_to_world(new_map_cell)
		
		new_world_cell.x += cell_size.x * 0.50
		new_world_cell.y += cell_size.y * 0.25
	
	return new_world_cell

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

func update_actor_list(actor, operation):
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
			_actor_list.append(actor)
		'remove':
			_actor_list.erase(actor)
