extends Node

# Stat info
var max_health = 0
var health = 0
var max_armor = 0
var armor = 0
var max_shields = 0
var shields = 0
var aim = 0
var speed = 0
var move = 0

################################################################################
# PUBLIC METHODS
################################################################################

func add_modifier():
	pass

#-------------------------------------------------------------------------------

func initialize(stats):
	max_health = stats.max_health
	health = stats.max_health
	max_armor = stats.max_armor
	armor = stats.max_armor
	max_shields = stats.max_shields
	shields = stats.max_shields
	aim = stats.aim
	speed = stats.speed
	move = stats.move

#-------------------------------------------------------------------------------

func provide_stats():
	var stats = {
		'max_health': max_health,
		'health': health,
		'max_armor': max_armor,
		'armor': armor,
		'max_shields': max_shields,
		'shields': shields,
		'aim': aim,
		'speed': speed,
		'move': move,
	}
	
	return stats

#-------------------------------------------------------------------------------

func recover_health():
	pass

#-------------------------------------------------------------------------------

func remove_modifier():
	pass

#-------------------------------------------------------------------------------

func take_damage(weapon):
	health -= weapon.provide_stats()['attack_damage']
	
	if health <= 0:
		health = 0
