extends Sprite

# Child nodes
onready var _stats = $Stats

# Weapon info
export (Resource) var weapon_loadout

################################################################################
# PUBLIC METHODS
################################################################################

func _ready():
	_stats.initialize(weapon_loadout)

################################################################################
# PUBLIC METHODS
################################################################################

func provide_stats():
	return _stats.provide_stats()
