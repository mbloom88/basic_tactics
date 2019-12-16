extends AStar

# Point info
var start = null
var start_type = ""
var goal = null
var grid_info = []

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

################################################################################
# PUBLIC METHODS
################################################################################

func initialize(pathing_info):
	start = pathing_info['battler']