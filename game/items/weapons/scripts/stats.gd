extends Node

# Weapon info
var attack_damage
var attack_range
var max_ammo
var ammo
var ammo_per_attack

################################################################################
# PUBLIC METHODS
################################################################################

func consume_ammo():
	ammo -= ammo_per_attack

#-------------------------------------------------------------------------------

func initialize(loadout):
	attack_damage = loadout.attack_damage
	attack_range = loadout.attack_range
	max_ammo = loadout.max_ammo
	ammo = loadout.max_ammo
	ammo_per_attack = loadout.ammo_per_attack

#-------------------------------------------------------------------------------

func provide_stats():
	var stats = {
		'attack_damage': attack_damage,
		'attack_range': attack_range,
		'max_ammo': max_ammo,
		'ammo': ammo,
		'ammo_per_attack': ammo_per_attack,
	}
	
	return stats

#-------------------------------------------------------------------------------

func reload():
	ammo = max_ammo
