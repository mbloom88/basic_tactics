extends "res://assets/scripts/state.gd"

# General battle parameters
var _turn_order = []

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

#-------------------------------------------------------------------------------

	static func speed_sorter(actor_a, actor_b):
		"""
		Sorts an Array of Actors by their Speed stat. Actors in the Array are
		sorted by highest speed first.
		"""
		var actor_a_move = actor_a.provide_job_info()['speed']
		var actor_b_move = actor_b.provide_job_info()['speed']
		if actor_a_move > actor_b_move:
			return true
		return false

################################################################################
# VIRTUAL METHODS
################################################################################

func _enter(host):
	host.set_process(false)
	host.emit_signal('begin_battle')
	_determine_turn_order(host)

################################################################################
# PRIVATE METHODS
################################################################################

#func _ai_attack_target(host):
#	yield(get_tree().create_timer(0.25), 'timeout') # Slows the ai down
#	host.emit_signal('load_target_actor_info', _target)
#	host.emit_signal('show_target_actor_gui_requested')
#	_target.show_battle_cursor()
#	yield(get_tree().create_timer(0.75), 'timeout') # Slows the ai down
#	_target.hide_battle_cursor()
#	_target.take_damage(_current_weapon)
#	host.emit_signal('load_target_actor_info', _target)

#-------------------------------------------------------------------------------

#func _determine_behavioral_ai_actions(host):
#	"""
#	Determines the type of battle actions that the current Enemy or NPC
#	Battler will take based on their behavioral profile.
#	"""
#	if _action_list.empty():
#		match _current_battler.battle_ai_behavior:
#			'aggressive_melee':
#				_action_list = ['move_to_attack', 'attack']
#
#	_next_ai_battle_action(host)

#-------------------------------------------------------------------------------

func _determine_turn_order(host):
	"""
	Determines a new battle turn order for all Battlers that are registered
	on the Battleground's grid.
	"""
	_turn_order = host.provide_battlers()
	_turn_order.sort_custom(CustomSorter, 'speed_sorter')
	setup_for_next_turn(host)

#-------------------------------------------------------------------------------

#func _find_attack_target_for_ai(host):
#	var battlers = host.provide_battlers()
#	var targets = []
#	var closest_target = {}
#	var current_type = ActorDatabase.lookup_type(_current_battler.reference)
#
#	# Look for Allies and NPCs if Enemy
#	if current_type == 'enemy':
#		for battler in battlers:
#			var target_type = ActorDatabase.lookup_type(battler.reference)
#			if target_type in ['ally', 'npc']:
#				targets.append(battler)
#	# Look for Enemies if NPC
#	elif current_type == 'npc':
#		for battler in battlers:
#			var target_type = ActorDatabase.lookup_type(battler.reference)
#			if target_type == 'enemy':
#				targets.append(battler)
#
#	# Find the closest target from targets list
#	var origin_cell = host.world_to_map(_current_battler.position)
#	for target in targets:
#		var target_cell = host.world_to_map(target.position)
#		var distance = origin_cell.distance_to(target_cell)
#		if not closest_target:
#			closest_target['target'] = target
#			closest_target['distance'] = distance
#		else:
#			if distance < closest_target['distance']:
#				closest_target['target'] = target
#				closest_target['distance'] = distance
#
#	_target = closest_target['target']

#-------------------------------------------------------------------------------

#func _find_closest_cell_near_target(host, action):
#	var action_range = 0
#	var origin_cell = host.world_to_map(_current_battler.position)
#	var target_cell = host.world_to_map(_target.position)
#	var used_map_cells = host.provide_used_cells('map')
#	var closest_cell = origin_cell
#	var target_distance = origin_cell.distance_to(target_cell)
#
#	match action:
#		'attack':
#			action_range = _current_weapon.provide_stats()['attack_range']
#
#	# Search for cell that puts Battler within range of the target
#	if target_distance > action_range:
#		var frontier = []
#		var visited = []
#		var history = []
#		frontier.append([origin_cell, target_distance])
#		visited.append(origin_cell)
#
#		# Scan all allowed movement cells
#		while not frontier.empty():
#			frontier.sort_custom(CustomSorter, 'distance_sorter')
#			var current = frontier.pop_front()
#			var current_cell = current[0]
#			var current_distance = current[1]
#
#			if current_distance <= action_range:
#				closest_cell = current_cell
#				break
#
#			history.append(current)
#
#			var neighbors = [
#				Vector2(current_cell.x, current_cell.y - 1), # up
#				Vector2(current_cell.x, current_cell.y + 1), # down
#				Vector2(current_cell.x - 1, current_cell.y), # left
#				Vector2(current_cell.x + 1, current_cell.y)] # right
#
#			for neighbor in neighbors:
#				if not neighbor in host._allowed_move_cells:
#					continue
#				if neighbor in visited:
#					continue
#				var distance = neighbor.distance_to(target_cell)
#				visited.append(neighbor)
#				frontier.append([neighbor, distance])
#
#		# If no cell is in range, get Battler as close to target as possible
#		if closest_cell == origin_cell:
#			var cell_info = {}
#			var neighbors = [
#				Vector2(target_cell.x, target_cell.y - 1), # up
#				Vector2(target_cell.x, target_cell.y + 1), # down
#				Vector2(target_cell.x - 1, target_cell.y), # left
#				Vector2(target_cell.x + 1, target_cell.y)] # right
#
#			for neighbor in neighbors:
#				var distance = origin_cell.distance_to(neighbor)
#				if cell_info.empty():
#					cell_info['cell'] = neighbor
#					cell_info['distance'] = distance
#				else:
#					if distance < cell_info['distance']:
#						cell_info['cell'] = neighbor
#						cell_info['distance'] = distance
#
#			closest_cell = cell_info['cell']
#	else:
#		closest_cell = origin_cell
#
#	return closest_cell

#-------------------------------------------------------------------------------

#func _next_ai_battle_action(host):
#	if _action_list.empty():
#		_current_battler.script_running = false
#		setup_for_next_turn(host)
#
#	var next_action = _action_list.pop_front()
#	yield(get_tree().create_timer(0.50), 'timeout') # Slows the ai down
#
#	match next_action:
#		'attack':
#			var attack_range = _current_weapon.provide_stats()['attack_range']
#			var current_cell = host.world_to_map(_current_battler.position)
#			var target_cell = host.world_to_map(_target.position)
#			var distance = current_cell.distance_to(target_cell)
#			if distance <= attack_range:
#				_ai_attack_target(host)
#			else:
#				_next_ai_battle_action(host)
#		'move_to_attack':
#			_find_attack_target_for_ai(host)
#			var closest_cell = _find_closest_cell_near_target(host, 'attack')
#			if closest_cell == host.world_to_map(_current_battler.position):
#				_next_ai_battle_action(host)
#			else:
#				_current_battler.scripted_state_change('move')
#				host._add_astar_instance(_current_battler, closest_cell)

#-------------------------------------------------------------------------------

#func _perform_next_ai_move(host):
#	if _move_list.empty():
#		_current_battler.deactivate()
#		_next_ai_battle_action(host)
#		return
#
#	var direction = _move_list.pop_front()
#	var origin_cell = host.world_to_map(_current_battler.position)
#	var next_cell = origin_cell + direction
#	if next_cell in host._allowed_move_cells:
#		_current_battler.perform_scripted_move(direction, 'run')
#	else:
#		_next_ai_battle_action(host)

################################################################################
# PUBLIC METHODS
################################################################################

func provide_current_battler_skills(host):
	var skills = host._current_battler.provide_skills()
	host.emit_signal('current_battler_skills_acquired', skills)

#-------------------------------------------------------------------------------

func setup_for_next_turn(host):
	"""
	Preparation for the next Battler's turn. Registers the next Battler in the
	turn order and its inventory before directing the battle Camera to the 
	Battler.
	"""
	if host._current_battler:
		host._current_battler.deactivate()
		host._current_battler = null
		host._remove_blinking_cells()
		host.emit_signal('hide_active_gui_requested')
		host.emit_signal('hide_target_gui_requested')
		host.emit_signal('hide_weapon_gui_requested')
	
	if _turn_order.empty():
		_determine_turn_order(host)
		return
	
	host._current_battler = _turn_order.pop_front()
	var move_range = host._current_battler.provide_job_info()['move']
	host._show_move_cells(host._current_battler)
	host._battle_camera.track_actor(host._current_battler)

#-------------------------------------------------------------------------------

func validate_skill_for_use(host, skill):
	if skill.reference == 'reload-weapon':
		host._current_battler.reload_current_weapon()
		host.emit_signal('refresh_weapon_info')
		host._current_battler.deactivate()
		yield(get_tree().create_timer(0.5), 'timeout')
		host.emit_signal('battle_action_completed')
		setup_for_next_turn(host)

################################################################################
# SIGNAL HANDLING
################################################################################

#func _on_Actor_move_completed(host, actor):
#	_perform_next_ai_move(host)

#-------------------------------------------------------------------------------

#func _on_AStarInstance_pathing_completed(host, path):
#	_move_list = path
#	_perform_next_ai_move(host)

#-------------------------------------------------------------------------------

func _on_BattleCamera_tracking_added(host, actor):
	"""
	Signal response after the battle Camera focuses on the next Battler in the
	turn order. The method then requests the ActiveActor GUI and activates the
	next Battler for its battle turn. If the next Battler is an Enemy or NPC, 
	the Battleground will assume control of the non-playable Battler.
	"""
	host.emit_signal('active_actor_selected', host._current_battler)
	var type = ActorDatabase.lookup_type(host._current_battler.reference)
	if type in ['enemy', 'npc']:
		host._current_battler.script_running = true
#		_determine_behavioral_ai_actions(host)
	else:
		host.emit_signal('show_weapon_gui_requested', host._current_battler)
		host._current_battler.activate_for_battle()
