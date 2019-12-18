extends NinePatchRect

# Child nodes
onready var _icon = $HBoxContainer/WeaponIcon
onready var _name = $HBoxContainer/VBoxContainer/WeaponName
onready var _ammo_prog = $HBoxContainer/VBoxContainer/AmmoProgress
onready var _ammo_value = $HBoxContainer/VBoxContainer/AmmoValues

# Panel info
export (bool) var hide_on_ready = false

# Weapon info
var _assigned_weapon = null

################################################################################
# VIRTUAL METHODS
################################################################################

func _ready():
	if hide_on_ready:
		hide_gui()

################################################################################
# PUBLIC METHODS
################################################################################

func activate():
	modulate.a = 1

#-------------------------------------------------------------------------------

func deactivate():
	modulate.a = 0.25
#-------------------------------------------------------------------------------

func hide_gui():
	visible = false

#-------------------------------------------------------------------------------

func load_weapon_info(weapon):
	"""
	Args:
		- weapon (Object):
	"""
	var stats = weapon.provide_stats()
	_assigned_weapon = weapon
	_icon.texture = ItemDatabase.lookup_icon(_assigned_weapon.reference)
	_name.text = '%s' % ItemDatabase.lookup_name(_assigned_weapon.reference)
	
	if stats.max_ammo == -1:
		_ammo_prog.max_value = 1
		_ammo_prog.value = 1
		_ammo_value.text = 'N/A'
	else:
		_ammo_prog.max_value = stats.max_ammo
		_ammo_prog.value = stats.ammo
		_ammo_value.text = '%s / %s' % [stats.ammo, stats.max_ammo]

#-------------------------------------------------------------------------------

func provide_assigned_weapon():
	return _assigned_weapon

#-------------------------------------------------------------------------------

func refresh_weapon_info():
	var stats = _assigned_weapon.provide_stats()
	
	if stats.max_ammo > -1:
		_ammo_prog.max_value = stats.max_ammo
		_ammo_prog.value = stats.ammo
		_ammo_value.text = '%s / %s' % [stats.ammo, stats.max_ammo]

#-------------------------------------------------------------------------------

func show_gui():
	visible = true
