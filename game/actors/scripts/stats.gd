extends Node

# Stat info
var max_health = 0
var health = 0
var max_armor = 0
var armor = 0
var max_shields = 0
var shields = 0
var aim = 0
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
	move = stats.move

#-------------------------------------------------------------------------------

func heal():
	pass

#-------------------------------------------------------------------------------

func remove_modifier():
	pass

#-------------------------------------------------------------------------------

func take_damage():
	pass
