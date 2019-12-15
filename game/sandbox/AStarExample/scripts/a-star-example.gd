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
#	astar.add_point(
