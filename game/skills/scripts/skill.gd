extends Node

# Skill info
export (String) var reference = ""
export (Resource) var skill_loadout
var cost
var damage

################################################################################
# PUBLIC METHODS
################################################################################

func _ready():
	initialize(skill_loadout)

################################################################################
# PUBLIC METHODS
################################################################################

func initialize(skill_loadout):
	cost = skill_loadout.cost
	damage = skill_loadout.damage

#-------------------------------------------------------------------------------

func provide_skill_stats():
	var skill_stats = {
		'cost': cost,
		'damage': damage,
	}
	return skill_stats
