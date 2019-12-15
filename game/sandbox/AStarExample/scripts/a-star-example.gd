extends "res://levels/scripts/level.gd"

# Child nodes
onready var _start = $Battleground/Battlers/TestEnemy001
onready var _finish = $Battleground/Battlers/TestAlly001

################################################################################
# VIRTUAL METHODS
################################################################################

func _ready():
	_start_astar()

################################################################################
# PRIVATE METHODS
################################################################################

func _start_astar():
	var astar = AStar.new()
	var grid = _battleground.provide_used_cells('world')
	var id = 1
	for cell in grid:
		var new_vector3 = Vector3(cell.x, cell.y, 0)
		astar.add_point(id, new_vector3, 1)
