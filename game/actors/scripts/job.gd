extends Node

# Child nodes
onready var _stats = $Stats
onready var _skills = $Skills

# Profession info
export (Resource) var job_loadout

################################################################################
# VIRTUAL METHODS
################################################################################

func _ready():
	_stats.initialize(job_loadout)
