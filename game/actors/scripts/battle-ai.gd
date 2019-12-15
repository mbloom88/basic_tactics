extends "res://assets/scripts/state.gd"

################################################################################
# VIRTUAL METHODS
################################################################################

func _enter(host):
	host.set_process(false)
	_determine_behavior(host)

################################################################################
# PRIVATE METHODS
################################################################################

func _determine_behavior(host):
	match host.battle_ai_behavior:
		'aggressive_melee':
			print('hey you')
