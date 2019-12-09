"""
Player party database. Stores squad and inventory information.
"""
extends Node

# Squad status
export (Dictionary) var squad_loadout = {
	'test_ally_001': {
		'hired': true,
		'in_squad': true,
		'essential': true,
	},
		'test_ally_002': {
		'hired': true,
		'in_squad': false,
		'essential': false,
	},
		'test_ally_003': {
		'hired': true,
		'in_squad': true,
		'essential': false,
	},
}

export (Dictionary) var inventory = {
	'shared': [],
	'test_ally_001': [], 
}

export (int) var squad_limit = 6 setget , get_squad_limit
var squad_count = 1 setget , get_squad_count

################################################################################
# PUBLIC METHODS
################################################################################

func provide_actor(ref):
	return squad_loadout[ref]

#-------------------------------------------------------------------------------

func provide_party():
	return squad_loadout

#-------------------------------------------------------------------------------

func update_squadie_status(ref, type):
	match type:
		'add':
			squad_loadout[ref]['in_squad'] = true
			squad_count += 1
		'remove':
			squad_loadout[ref]['in_squad'] = false
			squad_count -= 1

################################################################################
# GETTERS
################################################################################

func get_squad_count():
	return squad_count

#-------------------------------------------------------------------------------

func get_squad_limit():
	return squad_limit
