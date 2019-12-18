extends Node

# Signals
signal current_weapon_updated(current_weapon)

# Child nodes
onready var _weapon1 = $Weapon1.get_child(0)
onready var _weapon2 = $Weapon2.get_child(0)

# Weapon info 
var _current_weapon = null

################################################################################
# VIRTUAL METHODS
################################################################################

func _ready():
	_current_weapon = _weapon1

################################################################################
# PUBLIC METHODS
################################################################################

func provide_current_weapon():
	return _current_weapon

#-------------------------------------------------------------------------------

func provide_weapons():
	var weapons = {}
	weapons['weapon1'] = _weapon1
	weapons['weapon2'] = _weapon2
	
	return weapons

#-------------------------------------------------------------------------------

func swap_weapons():
	if _current_weapon == _weapon1:
		_current_weapon = _weapon2
	else:
		_current_weapon = _weapon1
	emit_signal('current_weapon_updated', _current_weapon)
