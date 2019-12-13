extends Sprite

# Child nodes
onready var _stats = $Stats

# Weapon info
export (String) var reference = "" setget , get_reference

################################################################################
# PUBLIC METHODS
################################################################################

func provide_stats():
	return _stats.provide_stats()

################################################################################
# GETTERS
################################################################################

func get_reference():
	return reference

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_Stats_stats_initialized():
	pass
