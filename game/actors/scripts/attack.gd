extends "res://assets/scripts/state.gd"

# Target info
var _targets = []
var _max_index = 0
var _index = 0

################################################################################
# VIRTUAL METHODS
################################################################################

func _enter(host):
	host.set_process(false)
	if host.has_ai_running:
		_ai_attack_target(host)
	else:
		host.emit_signal('attack_started', host)

#-------------------------------------------------------------------------------

func _update(host, delta):
	var action = _check_targets(host)
	
	if action:
		return action

################################################################################
# PRIVATE METHODS
################################################################################

func _ai_attack_target(host):
	var current_weapon = host.provide_weapons()['current']
	
	host.emit_signal('target_selected', host._ai_target)
	host._ai_target.show_battle_cursor()
	
	yield(get_tree().create_timer(1), 'timeout') # Slows the AI down
	host._ai_target.hide_battle_cursor()
	host._ai_target.take_damage(current_weapon)
	
	host._change_state('previous')

#-------------------------------------------------------------------------------

func _check_targets(host):
	var action = ""
	
	if Input.is_action_just_pressed("move_left") and _max_index >= 0:
		_targets[_index].hide_battle_cursor()
		if _index > 0:
			_index -= 1
		else:
			_index = _max_index
		_targets[_index].show_battle_cursor()
		host.emit_signal('target_selected', _targets[_index])
	elif Input.is_action_just_pressed("move_right") and _max_index >= 0:
		_targets[_index].hide_battle_cursor()
		if _index < _max_index:
			_index += 1
		else:
			_index = 0
		_targets[_index].show_battle_cursor()
		host.emit_signal('target_selected', _targets[_index])
	elif Input.is_action_just_pressed('ui_accept'):
		var has_attacked = _player_attack_target(host)
		if has_attacked:
			host.set_process(false)
			action = 'previous'
	elif Input.is_action_just_pressed('ui_cancel'):
		host.set_process(false)
		if _max_index >= 0:
			_targets[_index].hide_battle_cursor()
		host.emit_signal('move_cells_requested')
		host.emit_signal('hide_target_gui_requested')
		host.emit_signal('battle_action_cancelled')
		action = 'previous'

	return action

#-------------------------------------------------------------------------------

func _player_attack_target(host):
	"""
	Allows the Actor to attack a target if the Actor's Weapon has enough ammo.
	
	Returns:
		-has_attacked (bool): True if they player successfully attacked.
	"""
	var has_attacked = false
	var current_weapon = host.provide_weapons()['current']
	var stats = current_weapon.provide_stats()
	var ammo = stats['ammo']
	var max_ammo = stats['max_ammo']
	var ammo_per_attack = stats['ammo_per_attack']
	# Melee weapons
	if _max_index > -1 and max_ammo == -1:
		has_attacked = true
		_targets[_index].hide_battle_cursor()
		_targets[_index].take_damage(current_weapon)
	# Ranged weapons
	elif _max_index > -1 and ammo >= ammo_per_attack:
		has_attacked = true
		current_weapon.consume_ammo()
		_targets[_index].hide_battle_cursor()
		_targets[_index].take_damage(current_weapon)
	
	return has_attacked

################################################################################
# PUBLIC METHODS
################################################################################

func search_for_attack_targets(host, battle_info):
	"""
	Determines attack targets for the actor.
	
	Args:
		- host (Object): The actor.
		- battle_info (Dictionary): A dictionary of battle information provided
			by the Battleground.
	"""
	var current_weapon = host.provide_weapons()['current']
	var attack_range = current_weapon.provide_stats()['attack_range']
	var host_type = ActorDatabase.lookup_type(host.reference)
	var host_cell = battle_info['initiator'][host]
	_targets = []
	
	for target in battle_info['targets'].keys():
		var target_type = ActorDatabase.lookup_type(target.reference)
		var target_cell = battle_info['targets'][target]
		var distance_to_target = host_cell.distance_to(target_cell)
		if target_type != host_type and distance_to_target <= attack_range:
			_targets.append(target)
	
	host.emit_signal('attack_cells_requested', host, attack_range)
	
	if _targets.empty():
		_max_index = -1
	else:
		_max_index = _targets.size() - 1
	
	_index = 0
	host.set_process(true)
