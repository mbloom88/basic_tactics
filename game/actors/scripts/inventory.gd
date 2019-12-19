extends Node

# Signals
signal current_weapon_updated(current_weapon)
signal new_skills_loaded(skill_refs)

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

func load_item_skills():
	var skill_refs = []
	var weapon_skill_refs = \
		ItemDatabase.lookup_skills(_current_weapon.reference)
	
	for skill_ref in weapon_skill_refs:
		skill_refs.append(skill_ref)
	emit_signal('new_skills_loaded', skill_refs)
	
#-------------------------------------------------------------------------------

func provide_current_weapon():
	return _current_weapon

#-------------------------------------------------------------------------------

func provide_weapons():
	var weapons = {}
	weapons['weapon1'] = _weapon1
	weapons['weapon2'] = _weapon2
	
	return weapons

#-------------------------------------------------------------------------------

func reload_current_weapon():
	_current_weapon.reload()

#-------------------------------------------------------------------------------

func swap_weapons():
	if _current_weapon == _weapon1:
		_current_weapon = _weapon2
	else:
		_current_weapon = _weapon1
	emit_signal('current_weapon_updated', _current_weapon)
	load_item_skills()
