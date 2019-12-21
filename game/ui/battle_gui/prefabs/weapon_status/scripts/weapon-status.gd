extends NinePatchRect

# Child nodes
onready var _icon = $HBoxContainer/WeaponIcon
onready var _name = $HBoxContainer/VBoxContainer/WeaponName
onready var _ammo_prog = $HBoxContainer/VBoxContainer/AmmoProgress
onready var _ammo_value = $HBoxContainer/VBoxContainer/AmmoValues

# Weapon info
var current_weapon = null setget , get_current_weapon

################################################################################
# PUBLIC METHODS
################################################################################

func activate():
	modulate.a = 1

#-------------------------------------------------------------------------------

func deactivate():
	modulate.a = 0.25

#-------------------------------------------------------------------------------

func load_weapon(weapon):
	"""
	Args:
		- weapon (Object):
	"""
	current_weapon = weapon
	current_weapon.connect('ammo_consumed', self, '_on_Weapon_ammo_consumed')
	var stats = weapon.provide_stats()
	_icon.texture = ItemDatabase.lookup_icon(current_weapon.reference)
	_name.text = '%s' % ItemDatabase.lookup_name(current_weapon.reference)
	
	if stats.max_ammo == -1:
		_ammo_prog.max_value = 1
		_ammo_prog.value = 1
		_ammo_value.text = 'N/A'
	else:
		_ammo_prog.max_value = stats.max_ammo
		_ammo_prog.value = stats.ammo
		_ammo_value.text = '%s / %s' % [stats.ammo, stats.max_ammo]

################################################################################
# GETTERS
################################################################################

func get_current_weapon():
	return current_weapon

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_Weapon_ammo_consumed(amount):
	_ammo_prog.value -= amount
	_ammo_value.text = '%s / %s' % [_ammo_prog.value, _ammo_prog.max_value]
