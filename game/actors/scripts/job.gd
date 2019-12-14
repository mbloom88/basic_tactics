extends Node

# Child nodes
onready var _stats = $Stats
onready var _skills = $Skills

# Job info
export (Resource) var job_loadout
export (int) var level = 1 setget set_level
export (int) var level_cap = 20
var exp_current_level = 0
var exp_for_next_level = 0

################################################################################
# VIRTUAL METHODS
################################################################################

func _ready():
	_stats.initialize(job_loadout)

################################################################################
# PUBLIC METHODS
################################################################################

func calculate_exp_tnl(level):
	return round(pow(level, 1.8) + (4 * level))

#-------------------------------------------------------------------------------

func gain_experience(amount):
	if level != level_cap:
		exp_current_level += amount
	
		while exp_current_level >= exp_for_next_level:
			exp_current_level -= exp_for_next_level
			level_up()

#-------------------------------------------------------------------------------

func level_up():
	level += 1
	exp_for_next_level = calculate_exp_tnl(level)

#-------------------------------------------------------------------------------

func provide_job_info():
	var info = {
		'job_name': job_loadout.name,
		'level': level,
		'exp_current_level': exp_current_level,
		'exp_for_next_level': exp_for_next_level,
	}
	
	var stats = _stats.provide_stats()
	
	for stat in stats:
		info[stat] = stats[stat]
	
	return info

#-------------------------------------------------------------------------------

func take_damage(weapon_stats):
	_stats.take_damage(weapon_stats)

################################################################################
# SETTERS
################################################################################

func set_level(value):
	level = value

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_Stats_stats_initialized():
	pass # Replace with function body.
