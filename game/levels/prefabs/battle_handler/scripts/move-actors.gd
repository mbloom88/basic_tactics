extends "res://assets/scripts/state.gd"

var _active_allies = []

################################################################################
# VIRTUAL METHODS
################################################################################

func _enter(host):
	host.set_process(false)
	_gather_uninstantiated_allies(host)

#-------------------------------------------------------------------------------

func _update(host, delta):
	_check_actions()

################################################################################
# PRIVATE METHODS
################################################################################

func _check_actions():
	"""
	Looks for user inputs corresponding to specific actions.
	
	Returns:
		- action (Array): Two element array. Element 0 is the action to be
			performed. Element 1 is the value associated with that action. 
	"""
	
	if Input.is_action_just_pressed('menu_cycle_left'):
		print('left')
	elif Input.is_action_just_pressed("menu_cycle_right"):
		print('right')

#-------------------------------------------------------------------------------

func _gather_uninstantiated_allies(host):
	var ally_refs = ActorDatabase.provide_unlocked_allies()
	
	for ally_ref in ally_refs:
		var actors_in_scene = get_tree().get_nodes_in_group('actors')
		
		# If an ally is already in scene, erase its ref
		for actor in actors_in_scene:
			if actor.reference == ally_ref:
				ally_refs.erase(actor.reference)
	
	host.set_process(true)
