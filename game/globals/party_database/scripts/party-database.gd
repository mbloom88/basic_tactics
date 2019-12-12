"""
Player party database. Stores squad and inventory information.
"""
extends Node

export (int) var squad_limit setget , get_squad_limit
var allies_in_squad = 0 setget set_allies_in_squad, get_allies_in_squad

################################################################################
# SETTERS
################################################################################

func set_allies_in_squad(value):
	allies_in_squad = value

################################################################################
# GETTERS
################################################################################

func get_allies_in_squad():
	return allies_in_squad

#-------------------------------------------------------------------------------

func get_squad_limit():
	return squad_limit
