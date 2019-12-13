extends Node

# Signals
signal stats_initialized

# Weapon info
export (Resource) var weapon_loadout
var weapon_name
var weapon_type
var damage_type
var attack_damage
var attack_range
var max_ammo
var ammo_per_attack

################################################################################
# VIRTUAL METHODS
################################################################################

func _ready():
	_initialize(weapon_loadout)

################################################################################
# PRIVATE METHODS
################################################################################

func _initialize(loadout):
	weapon_name = loadout.weapon_name
	weapon_type = loadout.weapon_type
	damage_type = loadout.damage_type
	attack_damage = loadout.attack_damage
	attack_range = loadout.attack_range
	max_ammo = loadout.max_ammo
	ammo_per_attack = loadout.ammo_per_attack

################################################################################
# PUBLIC METHODS
################################################################################

func provide_stats():
	var stats = {
		'weapon_name': weapon_name,
		'weapon_type': weapon_type,
		'damage_type': damage_type,
		'attack_damage': attack_damage,
		'attack_range': attack_range,
		'max_ammo': max_ammo,
		'ammo_per_attack': ammo_per_attack,
	}
	
	return stats
