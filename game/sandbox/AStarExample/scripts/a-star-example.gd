extends "res://levels/scripts/level.gd"

# Child nodes
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
	var _start = $Battleground/Battlers/TestEnemy001
	var start_type = ActorDatabase.lookup_type(_start.reference)
	var vector2_point = _battleground.world_to_map(_start.position)
	var start_point = Vector3(vector2_point.x, vector2_point.y, 0)
	var start_id = _calculate_point_index(start_point)
	
	var _target = $Battleground/Battlers/TestAlly001
	vector2_point = _battleground.world_to_map(_target.position)
	var target_point = Vector3(vector2_point.x, vector2_point.y, 0)
	
	_set_astar_points(start_type)
	var goal_point = _find_closest_cell_to_target(target_point)
	var goal_id = _calculate_point_index(goal_point)
	_connect_astar_points(start_point, goal_point)
	var path_v3 = _astar.get_point_path(start_id, goal_id)
	var path_v2 = []

	for cell in path_v3:
		path_v2.append(Vector2(cell.x, cell.y))
	
	print(path_v3)
	
	_battleground._add_blinking_cells(path_v2)
	
################################################################################
# PRIVATE METHODS
################################################################################

func _calculate_point_index(point):
	"""
	Returns a unique ID for a point in the AStar grid. Uses a Cantor pairing 
	function to create the unique ID using the x and y points.
	
	NOTE: Cannot be used for negative integers!
	"""
	return (((point.x + point.y) * (point.x + point.y + 1)) / 2) + point.y

#-------------------------------------------------------------------------------

func _connect_astar_points(start_point, goal_point):
	var frontier = []
	var visited = []
	
	var map_cells_v2 = _battleground.provide_used_cells('map')
	var map_cells_v3 = []
	for map_cell in map_cells_v2:
		map_cells_v3.append(Vector3(map_cell.x, map_cell.y, 0))
	
	frontier.append([start_point, 0])
	
	while not frontier.empty():
		frontier.sort_custom(CustomSorter, 'priority_sorter')
		var current_point = frontier.pop_front()[0]
		
		if current_point == goal_point:
			break
		
		var current_id = _calculate_point_index(current_point)
		var neighbors = [
			Vector3(current_point.x, current_point.y - 1, 0), # up
			Vector3(current_point.x, current_point.y + 1, 0), # down
			Vector3(current_point.x - 1, current_point.y, 0), # left
			Vector3(current_point.x + 1, current_point.y, 0)] # right
		
		visited.append(current_point)
		
		for neighbor in neighbors:
			var neighbor_id = _calculate_point_index(neighbor)
			if not neighbor in map_cells_v3:
				continue
			elif not neighbor_id in _astar.get_points():
				continue
			elif neighbor in visited:
				continue
			
			# Manhattan distance
			var cost = abs(goal_point.x - neighbor.x) + \
				abs(goal_point.y - neighbor.y)
			frontier.append([neighbor, cost])
			_astar.connect_points(current_id, neighbor_id, false)

#-------------------------------------------------------------------------------

func _find_closest_cell_to_target(target_point):
	"""
	Find the closest cell to a Battler target on the Battleground.
	
	Args:
		- target_point (Vector3): The target point that will be used to scan
			neighboring points for open spaces.
	
	Returns:
		- closest_point (Vector3): The closest, open point to the target point.
			Will return Null if no neighboring spaces to the target are open.
	"""
	var used_map_cells = _battleground.provide_used_cells('map')
	var closest_point = null
	var neighbors = [
			Vector2(target_point.x, target_point.y - 1), # up
			Vector2(target_point.x, target_point.y + 1), # down
			Vector2(target_point.x - 1, target_point.y), # left
			Vector2(target_point.x + 1, target_point.y)] # right
	
	for neighbor in neighbors:
		if not neighbor in used_map_cells:
			continue
		elif _battleground._check_obstacle(neighbor):
			continue
		else:
			closest_point = Vector3(neighbor.x, neighbor.y, 0)
	
	return closest_point

#-------------------------------------------------------------------------------

func _set_astar_points(start_type):
	"""
	Provides points to the AStar algorithm for pathing consideration.
	"""
	var map_points = _battleground.provide_used_cells('map')
	var edited_points = []
	
	# Remove cells that are blocked by opposing actor types, non-battlers, and
	# objects.
	for point in map_points:
		var obstacle = _battleground._check_obstacle(point)
		if obstacle:
			var obstacle_type = ActorDatabase.lookup_type(obstacle.reference)
			if obstacle_type != start_type:
				continue
			else:
				edited_points.append(point)
		else:
			edited_points.append(point)
	
	# Add points to AStar
	for point in edited_points:
		var id = _calculate_point_index(point)
		var new_vector3 = Vector3(point.x, point.y, 0)
		_astar.add_point(id, new_vector3, 1)
