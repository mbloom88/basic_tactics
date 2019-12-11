extends "res://assets/scripts/state.gd"

var _active_allies = []
var _ally_index = 0
var _max_index = 0

################################################################################
# VIRTUAL METHODS
################################################################################

func _enter(host):
	host.set_process(false)
	_gather_uninstantiated_allies(host)

#-------------------------------------------------------------------------------

func _update(host, delta):
	_check_actions(host)

################################################################################
# PRIVATE METHODS
################################################################################

func _check_actions(host):
	"""
	Looks for user inputs corresponding to specific actions.
	
	Returns:
		- action (Array): Two element array. Element 0 is the action to be
			performed. Element 1 is the value associated with that action. 
	"""
	
	if Input.is_action_just_pressed('ui_left'):
		if _ally_index == 0:
			_ally_index = _max_index
		else:
			_ally_index -= 1
	elif Input.is_action_just_pressed("ui_right"):
		if _ally_index == _max_index:
			_ally_index = 0
		else:
			_ally_index += 1

	host._active_panel.load_portrait(_active_allies[_ally_index])

#-------------------------------------------------------------------------------

func _gather_uninstantiated_allies(host):
	var ally_refs = ActorDatabase.provide_unlocked_allies()
	
	for ally_ref in ally_refs:
		var actors_in_scene = get_tree().get_nodes_in_group('actors')
		
		# If an ally is already in scene, erase its ref
		for actor in actors_in_scene:
			if actor.reference == ally_ref:
				ally_refs.erase(actor.reference)
	
	_active_allies = ally_refs
	_max_index = len(_active_allies) - 1
	_show_ally_select_gui(host)

#-------------------------------------------------------------------------------

func _show_ally_select_gui(host):
	host._active_panel.show_gui()
	host._active_panel.load_portrait(_active_allies[0])
	host.set_process(true)
