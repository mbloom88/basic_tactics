extends Node

# Weapon info
var weapon_type
var damage_type
var attack_damage
var attack_range
var max_ammo
var ammo
var ammo_per_attack

################################################################################
# PUBLIC METHODS
################################################################################

func initialize(loadout):
	weapon_type = loadout.weapon_type
	damage_type = loadout.damage_type
	attack_damage = loadout.attack_damage
	attack_range = loadout.attack_range
	max_ammo = loadout.max_ammo
	ammo = loadout.max_ammo
	ammo_per_attack = loadout.ammo_per_attack

#-------------------------------------------------------------------------------

func provide_stats():
	var stats = {
		'weapon_type': weapon_type,
		'damage_type': damage_type,
		'attack_damage': attack_damage,
		'attack_range': attack_range,
		'max_ammo': max_ammo,
		'ammo': ammo,
		'ammo_per_attack': ammo_per_attack,
	}
	
	return stats
