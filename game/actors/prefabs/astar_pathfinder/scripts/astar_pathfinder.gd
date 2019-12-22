extends Node

# Signals
signal pathing_completed(path)

# AStar
onready var _astar = AStar.new()

# Point info
var _actor = null
var _start_point = null
var _start_type = ""
var _start_id = -1
var _goal_point = null
var _goal_id = -1
var _walkable_points = []

################################################################################
# CLASSES
################################################################################

class CustomSorter:
	
	static func priority_sorter(frontier_a, frontier_b):
		"""
		Sorts an Array of frontier points based on their priority cost to
		get to the goal. Lower costs are prioritized.
		"""
		var cost_a = frontier_a[1]
		var cost_b = frontier_b[1]
		if cost_a < cost_b:
			return true
		return false

################################################################################
# PRIVATE METHODS
################################################################################

func _calculate_astar_path():
	"""
	Calculates a pathway between the starting and goal points. 
	
	Returns:
		- directions (Array): A list of Vector2 directions between the starting
			and goal points. Returns as Empty if no pathway is found.
	"""
	_set_astar_points()
	_connect_astar_points()
	var pathway_vector3 = Array(_astar.get_point_path(_start_id, _goal_id))
	var directions = []
	var previous_point = pathway_vector3.pop_front()
	
	# Converts map cells to directions
	for point in pathway_vector3:
		var x = int(sign(point.x - previous_point.x))
		var y = int(sign(point.y - previous_point.y))
		directions.append(Vector2(x, y))
		previous_point = point
	
	emit_signal('pathing_completed', directions)
	_astar.clear()

#-------------------------------------------------------------------------------

func _calculate_point_index(point):
	"""
	Returns a unique ID for a point in the AStar grid. Uses a Cantor pairing 
	function to create the unique ID using the x and y points.
	
	NOTE: Cannot be used for negative integers!
	"""
	return (((point.x + point.y) * (point.x + point.y + 1)) / 2) + point.y

#-------------------------------------------------------------------------------

func _connect_astar_points():
	"""
	Connects all possible paths together until the goal point is reached.
	"""
	var frontier = []
	var visited = []
	
	frontier.append([_start_point, 0])
	
	while not frontier.empty():
		frontier.sort_custom(CustomSorter, 'priority_sorter')
		var current_point = frontier.pop_front()[0]
		
		if current_point == _goal_point:
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
			if not neighbor in _walkable_points:
				continue
			elif not neighbor_id in _astar.get_points():
				continue
			elif neighbor in visited:
				continue
			
			# Manhattan distance calculation for grid
			var cost = abs(_goal_point.x - neighbor.x) + \
				abs(_goal_point.y - neighbor.y)
			frontier.append([neighbor, cost])
			_astar.connect_points(current_id, neighbor_id, false)

#-------------------------------------------------------------------------------

func _set_astar_points():
	"""
	Places points for the AStar algorithm to connect pathways between.
	"""
	for point in _walkable_points:
		var id = _calculate_point_index(point)
		_astar.add_point(id, point, 1)

################################################################################
# PUBLIC METHODS
################################################################################

func initialize(pathing_info):
	"""
	Initializes the AStar node with the following Dictionary information.
	
	- pathing_info['actor']: The Actor the AStar instance is dedicated to.
	
	- pathing_info['actor_cell']: The Vector2 map cell that current Actor is
		standing in.
	
	- pathing_info['goal_cell']: The Vector2 map cell that the goal is located
		in.
	
	- pathing_info['walkable_cells']: An Array of Vector2 map cells that the 
		Actor is allowed to traverse. The list of map cells should already
		have taken into consideration objects for this pathing algorithm
		to work accurately.
	"""
	# Actor info
	var _actor = pathing_info['actor']
	
	# Start info
	var start_vector2 = pathing_info['actor_cell']
	_start_point = Vector3(start_vector2.x, start_vector2.y, 0)
	_start_type = ActorDatabase.lookup_type(_actor.reference)
	_start_id = _calculate_point_index(_start_point)
	
	# Goal info
	var goal_vector2 = pathing_info['goal_cell']
	_goal_point = Vector3(goal_vector2.x, goal_vector2.y, 0)
	_goal_id = _calculate_point_index(_goal_point)
	
	# Battleground grid info
	var walkable_points_vector2 = pathing_info['walkable_cells']
	for point in walkable_points_vector2:
		_walkable_points.append(Vector3(point.x, point.y, 0))
	
	_calculate_astar_path()
