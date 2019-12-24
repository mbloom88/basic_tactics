extends "res://assets/scripts/state.gd"

var _action_list = []
var _weapon1 = null
var _weapon2 = null
var _current_weapon = null
var _battleground_info = {}

################################################################################
# CLASSES
################################################################################

class CustomSorter:
	
	static func distance_sorter(frontier_a, frontier_b):
		"""
		Sorts an Array of frontier points based on their priority cost to
		get to the goal. Lower costs are prioritized.
		"""
		var distance_a = frontier_a[1]
		var distance_b = frontier_b[1]
		if distance_a < distance_b:
			return true
		return false

################################################################################
# VIRTUAL METHODS
################################################################################

func _enter(host):
	host.set_process(false)
	_update_weapon_info(host)
	_determine_actions(host)

################################################################################
# PRIVATE METHODS
################################################################################

func _determine_actions(host):
	"""
	Determines the type of actions that the current Enemy or NPC will take
	based on their behavioral profile or CommandProgram scripting status.
	"""
	if _action_list.empty():
		match host.battle_ai_behavior:
			'aggressive_melee':
				_action_list = [
					'move_to_attack',
					'update_battleground_info', 
					'attack']

	host.emit_signal('ai_actions_set', host)

#-------------------------------------------------------------------------------

func _find_attack_target_for_ai(host):
	var attack_targets = []
	var closest_target = {}
	var current_type = ActorDatabase.lookup_type(host.reference)

	# Look for Allies and NPCs if Enemy
	if current_type == 'enemy':
		for target in _battleground_info['targets'].keys():
			var target_type = ActorDatabase.lookup_type(target.reference)
			if target_type in ['ally', 'npc']:
				attack_targets.append(target)
	# Look for Enemies if NPC
	elif current_type == 'npc':
		for target in _battleground_info['targets'].keys():
			var target_type = ActorDatabase.lookup_type(target.reference)
			if target_type == 'enemy':
				attack_targets.append(target)

	# Find the closest target from targets list
	var origin_cell = _battleground_info['initiator'][host]
	for target in attack_targets:
		var target_cell = _battleground_info['targets'][target]
		var distance = origin_cell.distance_to(target_cell)
		if not closest_target:
			closest_target['target'] = target
			closest_target['distance'] = distance
		else:
			if distance < closest_target['distance']:
				closest_target['target'] = target
				closest_target['distance'] = distance

	host._ai_target = closest_target['target']

#-------------------------------------------------------------------------------

func _find_closest_cell_near_target(host, action):
	var action_range = 0
	var origin_cell = _battleground_info['initiator'][host]
	var target_cell = _battleground_info['targets'][host._ai_target]
	var closest_cell = origin_cell
	var target_distance = origin_cell.distance_to(target_cell)

	match action:
		'attack':
			action_range = _current_weapon.provide_stats()['attack_range']

	# Search for cell that puts AI within range of the target
	if target_distance > action_range:
		var frontier = []
		var visited = []
		var history = []
		frontier.append([origin_cell, target_distance])
		visited.append(origin_cell)

		# Scan all allowed movement cells
		while not frontier.empty():
			frontier.sort_custom(CustomSorter, 'distance_sorter')
			var current = frontier.pop_front()
			var current_cell = current[0]
			var current_distance = current[1]

			if current_distance <= action_range:
				closest_cell = current_cell
				break

			history.append(current)

			var neighbors = [
				Vector2(current_cell.x, current_cell.y - 1), # up
				Vector2(current_cell.x, current_cell.y + 1), # down
				Vector2(current_cell.x - 1, current_cell.y), # left
				Vector2(current_cell.x + 1, current_cell.y)] # right

			for neighbor in neighbors:
				if not neighbor in _battleground_info['move_cells']:
					continue
				if neighbor in visited:
					continue
				var distance = neighbor.distance_to(target_cell)
				visited.append(neighbor)
				frontier.append([neighbor, distance])

		# If no cell is in range, get AI as close to target as possible
		if closest_cell == origin_cell:
			var cell_info = {}
			var neighbors = [
				Vector2(target_cell.x, target_cell.y - 1), # up
				Vector2(target_cell.x, target_cell.y + 1), # down
				Vector2(target_cell.x - 1, target_cell.y), # left
				Vector2(target_cell.x + 1, target_cell.y)] # right

			for neighbor in neighbors:
				var distance = origin_cell.distance_to(neighbor)
				if cell_info.empty():
					cell_info['cell'] = neighbor
					cell_info['distance'] = distance
				else:
					if distance < cell_info['distance']:
						cell_info['cell'] = neighbor
						cell_info['distance'] = distance

			closest_cell = cell_info['cell']
	else:
		closest_cell = origin_cell

	return closest_cell

#-------------------------------------------------------------------------------

func _update_weapon_info(host):
	var weapons = host.provide_weapons()
	_weapon1 = weapons['weapon1']
	_weapon2 = weapons['weapon2']
	_current_weapon = weapons['current']

################################################################################
# PUBLIC METHODS
################################################################################

func next_ai_action(host):
	if _action_list.empty():
		return

	var next_action = _action_list.pop_front()
	yield(get_tree().create_timer(0.25), 'timeout') # Slows the AI down
	
	match next_action:
		'attack':
			var attack_range = _current_weapon.provide_stats()['attack_range']
			var current_cell = _battleground_info['initiator'][host]
			var target_cell = _battleground_info['targets'][host._ai_target]
			var distance = current_cell.distance_to(target_cell)
			if distance <= attack_range:
				host.emit_signal('attack_cells_requested', host, attack_range)
				host._change_state('attack')
			else:
				next_ai_action(host)
		'move_to_attack':
			_find_attack_target_for_ai(host)
			var closest_cell = _find_closest_cell_near_target(host, 'attack')
			if closest_cell == _battleground_info['initiator'][host]:
				next_ai_action(host)
			else:
				var pathing_info = {}
				pathing_info['actor'] = host
				pathing_info['actor_cell'] = \
					_battleground_info['initiator'][host]
				pathing_info['goal_cell'] = closest_cell
				pathing_info['walkable_cells'] = \
					_battleground_info['move_cells']
				host._astar.initialize(pathing_info)
		'update_battleground_info':
			host.emit_signal('battleground_info_requested', host)

#-------------------------------------------------------------------------------

func update_ai_battleground_info(host, battleground_info):
	"""
	Args:
		- battle_info (Dictionary): A dictionary that holds the requesting actor
			as a key within its current map cell as a value. Targets are listed 
			as keys and their associated map cells are their values. The map
			cells can be used for determining distances.
	"""
	_battleground_info = battleground_info
	next_ai_action(host)

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_AStarPathfinder_pathing_completed(host, path):
	host._ai_movements = path
	host._change_state('move')
