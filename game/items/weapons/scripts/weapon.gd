extends Sprite

# Signals 
signal ammo_consumed(amount)

# Child nodes
onready var _stats = $Stats

# Weapon info
export (String) var reference = ""
export (Resource) var weapon_loadout

################################################################################
# PUBLIC METHODS
################################################################################

func _ready():
	_stats.initialize(weapon_loadout)

################################################################################
# PUBLIC METHODS
################################################################################

func consume_ammo():
	_stats.consume_ammo()

#-------------------------------------------------------------------------------

func provide_stats():
	return _stats.provide_stats()

#-------------------------------------------------------------------------------

func reload():
	_stats.reload()

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_Stats_ammo_consumed(amount):
	emit_signal('ammo_consumed', amount)
