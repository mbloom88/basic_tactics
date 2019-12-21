extends Node

# Signals
signal item_skills_requested
signal stats_modified
signal weapon_reload_requested

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

func load_job_skills():
	_skills.load_job_skills(job_loadout.skill_references)

#-------------------------------------------------------------------------------

func load_weapon_skills(skill_refs):
	_skills.load_weapon_skills(skill_refs)

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

func provide_skills():
	return _skills.provide_skills()

#-------------------------------------------------------------------------------

func take_damage(weapon):
	_stats.take_damage(weapon)
	emit_signal('stats_modified')

#-------------------------------------------------------------------------------

func use_skill(skill):
	_skills.use_skill(skill)

################################################################################
# SETTERS
################################################################################

func set_level(value):
	level = value

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_Skills_weapon_reload_requested():
	emit_signal('weapon_reload_requested')
