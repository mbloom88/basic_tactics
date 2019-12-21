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
	host.emit_signal('attack_started', host)

################################################################################
# PRIVATE METHODS
################################################################################

func _check_targets(host):
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
		_player_attack_target(host)
	elif Input.is_action_just_pressed('ui_cancel'):
		host.set_process(false)
		if _max_index >= 0:
			_targets[_index].hide_battle_cursor()
		var move_range = host.provide_job_info()['move']
		host.emit_signal('move_cells_requested', host, move_range)
		host.emit_signal('battle_action_cancelled')

#-------------------------------------------------------------------------------

func _player_attack_target(host):
	"""
	Allows the Actor to attack a target if the Actor's Weapon has enough ammo.
	"""
	var current_weapon = host.provide_current_weapon().provide_stats()
	var ammo = current_weapon['ammo']
	var max_ammo = current_weapon['max_ammo']
	var ammo_per_attack = current_weapon['ammo_per_attack']
	# Melee weapons
	if _max_index > -1 and max_ammo == -1:
		host.set_process(false)
		host.emit_signal('battle_action_completed')
		_targets[_index].hide_battle_cursor()
		_targets[_index].take_damage(current_weapon)
		host.emit_signal('load_target_actor_info', _targets[_index])
	# Ranged weapons
	elif _max_index > -1 and ammo >= ammo_per_attack:
		host.set_process(false)
		host.emit_signal('battle_action_completed')
		current_weapon.consume_ammo()
		host.emit_signal('refresh_weapon_info')
		_targets[_index].hide_battle_cursor()
		_targets[_index].take_damage(current_weapon)
		host.emit_signal('load_target_actor_info', _targets[_index])

################################################################################
# PUBLIC METHODS
################################################################################

func search_for_attack_targets(host, target_info):
	"""
	Determines attack targets for the actor.
	
	Args:
		- host (Object): The actor.
		- target_info (Dictionary): A dictionary that holds the requesting actor
			as a key within its current map cell as a value. Targets are listed 
			as keys and their associated map cells are their values. The map
			cells can be used for determining distances.
	"""
	var attack_range = \
		host.provide_current_weapon().provide_stats()['attack_range']
	var host_type = ActorDatabase.lookup_type(host.reference)
	var host_cell = target_info['initiator'][host]
	_targets = []
	
	for target in target_info['targets'].keys():
		var target_type = ActorDatabase.lookup_type(target.reference)
		var target_cell = target_info['targets'][target]
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
