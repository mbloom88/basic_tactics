extends Node

# Child nodes
onready var _weapon1 = $Weapon1
onready var _weapon2 = $Weapon2

# Weapon info
var _current_weapon = null

################################################################################
# VIRTUAL METHODS
################################################################################

func _ready():
	_current_weapon = _weapon1.get_child(0)

################################################################################
# PUBLIC METHODS
################################################################################

func provide_weapon():
	return _current_weapon
