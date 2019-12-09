"""
Player party database. Stores squad and inventory information.
"""
extends Node

export (int) var squad_limit = 6 setget , get_squad_limit

################################################################################
# GETTERS
################################################################################

func get_squad_limit():
	return squad_limit
