extends NinePatchRect

# Child nodes
onready var _icon = $HBoxContainer/WeaponIcon
onready var _name = $HBoxContainer/VBoxContainer/WeaponName
onready var _damage = $HBoxContainer/VBoxContainer/Damage
onready var _range = $HBoxContainer/VBoxContainer/Range
onready var _ammo = $HBoxContainer/VBoxContainer/Ammo

################################################################################
# VIRTUAL METHODS
################################################################################

func _ready():
	hide_gui()

################################################################################
# PUBLIC METHODS
################################################################################

func hide_gui():
	visible = false

#-------------------------------------------------------------------------------

func load_weapon_info(weapon):
	"""
	Args:
		- weapon (Object):
	"""
	var stats = weapon.provide_stats()
	_icon.texture = ItemDatabase.lookup_icon(weapon.reference)
	_name.text = '%s' % ItemDatabase.lookup_name(weapon.reference)
	_damage.text = 'Damage: %s' % stats.attack_damage
	_range.text = 'Range: %s' % stats.attack_range
	if stats.max_ammo == -1:
		_ammo.text = 'Ammo: N/A'
	else:
		_ammo.text = 'Ammo: %s / %s' % [stats.ammo, stats.max_ammo]

#-------------------------------------------------------------------------------

func show_gui():
	visible = true