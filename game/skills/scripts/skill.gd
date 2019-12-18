extends Node

# Skill info
export (String) var reference = ""
export (Resource) var skill_loadout
var resouce_type = ""
var resource_per_use = -1

################################################################################
# PUBLIC METHODS
################################################################################

func _ready():
	initialize(skill_loadout)

################################################################################
# PUBLIC METHODS
################################################################################

func initialize(skill_loadout):
	resouce_type = skill_loadout.resource_type
	resource_per_use = skill_loadout.resource_per_use

#-------------------------------------------------------------------------------

func provide_skill():
	return self

#-------------------------------------------------------------------------------

func use_skill():
	pass
