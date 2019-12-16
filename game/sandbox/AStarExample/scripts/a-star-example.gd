extends "res://levels/scripts/level.gd"

# Child nodes
onready var _start = $Battleground/Battlers/TestEnemy001
onready var _target = $Battleground/Battlers/TestAlly001
onready var _astar = AStar.new()

################################################################################
# CLASSES
################################################################################

class CustomSorter:
	
	static func priority_sorter(frontier_a, frontier_b):
		"""
		Sorts an Array of frontier points based on their priority cost to
		get to the target/goal. Lower costs are prioritized.
		"""
		var cost_a = frontier_a[1]
		var cost_b = frontier_b[1]
		if cost_a < cost_b:
			return true
		return false

################################################################################
# VIRTUAL METHODS
################################################################################

func _ready():
	var vector2_point = _battleground.world_to_map(_start.position)
	var start_point = Vector3(vector2_point.x, vector2_point.y, 0)
	var ids = _set_astar_points()
	var target_point = _find_closest_cell_to_target()
#	_connect_astar_points(ids, target_point)
	print(_astar.get_point_path(ids[start_point], ids[target_point]))

################################################################################
# PRIVATE METHODS
################################################################################

func _connect_astar_points(ids, target_cell):
	var vector2_point = _battleground.world_to_map(_start.position)
	var start_point = Vector3(vector2_point.x, vector2_point.y, 0)
	var frontier = []
	var visited = []
	
	frontier.append([start_point, 0])
	
	while not frontier.empty():
		frontier.sort_custom(CustomSorter, 'priority_sorter')
		
		var current_point = frontier.pop_front()[0]
		var neighbors = [
			Vector3(current_point.x, current_point.y - 1, 0), # up
			Vector3(current_point.x, current_point.y + 1, 0), # down
			Vector3(current_point.x - 1, current_point.y, 0), # left
			Vector3(current_point.x + 1, current_point.y, 0)] # right
		
		visited.append(current_point)
		
		for neighbor in neighbors:
			if neighbor == target_cell:
				break
			if not neighbor in _astar.get_points():
				continue
			if neighbor in visited:
				continue
			
			# Manhattan distance
			var cost = abs(target_cell.x - neighbor.x) + \
				abs(target_cell.y - neighbor.y)
			frontier.append([neighbor, cost])
			_astar.connect_points(ids[current_point], ids[neighbor], false)
			
			print(frontier) # TEST PRINT
			
#-------------------------------------------------------------------------------

func _find_closest_cell_to_target():
	"""
	Find the closest cell next to the target.
	
	Returns:
		- closest_cell (Vector2) the closest cell next to the target that is
			also the closest to the current Battler.
	"""
	var target_cell = _battleground.world_to_map(_target.position)
	var vector_3_cell = Vector3(target_cell.x, target_cell.y, 0)
	var closest_id = _astar.get_closest_point(vector_3_cell)
	var closest_cell = _astar.get_point_position(closest_id)
	
	return closest_cell

#-------------------------------------------------------------------------------

func _set_astar_points():
	"""
	Provides points to the AStar algorithm for pathing consideration.
	
	Returns:
		- ids (Dictionary): Vector3 (key) and ID (value) pairs.
	"""
	var points = _battleground.provide_used_cells('map')
	var origin_type = ActorDatabase.lookup_type(_start.reference)
	var ids = {}
	var id = 0
	
	# Remove cells that are blocked by opposing actor types, non-battlers, and
	# objects.
	for point in points:
		var obstacle = _battleground._check_obstacle(point)
		if obstacle:
			var obstacle_type = ActorDatabase.lookup_type(obstacle.reference)
			if origin_type != obstacle_type:
				points.erase(point)
	
	# Add points to AStar
	for point in points:
		var new_vector3 = Vector3(point.x, point.y, 0)
		_astar.add_point(id, new_vector3, 1)
		ids[new_vector3] = id
		id += 1
		
	return ids
