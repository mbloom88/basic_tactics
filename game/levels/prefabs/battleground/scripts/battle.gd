extends "res://assets/scripts/state.gd"

# General battle parameters
var _turn_order = []
var _current_battler = null
var _weapon1 = null
var _weapon2 = null
var _current_weapon = null
var _current_action = ""
var _valid_targets = []
var _max_target_index = 0
var _target_index = 0
var _allowed_action_cells = []

# AI parameters
var _action_list = []
var _move_list = []
var _target = null

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

#-------------------------------------------------------------------------------

func _update(host, delta):
	_check_targets_for_player(host)

################################################################################
# PRIVATE METHODS
################################################################################

func _ai_attack_target(host):
	_determine_attack_cells(host)
	yield(get_tree().create_timer(0.25), 'timeout') # Slows the ai down
	host.emit_signal('load_target_actor_info', _target)
	host.emit_signal('show_target_actor_gui_requested')
	_target.show_battle_cursor()
	yield(get_tree().create_timer(0.75), 'timeout') # Slows the ai down
	_target.hide_battle_cursor()
	_target.take_damage(_current_weapon)
	host.emit_signal('load_target_actor_info', _target)

#-------------------------------------------------------------------------------

func _check_targets_for_player(host):
	if Input.is_action_just_pressed("move_left") and _max_target_index >= 0:
		_valid_targets[_target_index].hide_battle_cursor()
		if _target_index > 0:
			_target_index -= 1
		else:
			_target_index = _max_target_index
		_valid_targets[_target_index].show_battle_cursor()
		host.emit_signal('load_target_actor_info', _valid_targets[_target_index])
		host.emit_signal('show_target_actor_gui_requested')
	elif Input.is_action_just_pressed("move_right") and _max_target_index >= 0:
		_valid_targets[_target_index].hide_battle_cursor()
		if _target_index < _max_target_index:
			_target_index += 1
		else:
			_target_index = 0
		_valid_targets[_target_index].show_battle_cursor()
		host.emit_signal('load_target_actor_info', _valid_targets[_target_index])
		host.emit_signal('show_target_actor_gui_requested')
	# Affect target with item
	elif Input.is_action_just_pressed('ui_accept'):
		if _current_action == 'attack':
			_player_attack_target(host)
	# Cancel action
	elif Input.is_action_just_pressed('ui_cancel'):
		host.set_process(false)
		_current_action = ""
		host.emit_signal('hide_target_actor_gui_requested')
		if _max_target_index >= 0:
			_valid_targets[_target_index].hide_battle_cursor()
		host._remove_blinking_cells()
		host._add_blinking_cells(host._allowed_move_cells)
		host.emit_signal('battle_action_cancelled')

#-------------------------------------------------------------------------------

func _determine_attack_cells(host):
	"""
	Determines the attack range for the current Battler and then displays the
	allowable range.
	"""
	var origin_map_cell = host.world_to_map(_current_battler.position)
	var attack_range = _current_weapon.provide_stats()['attack_range']
	var used_cells = host.provide_used_cells('map')
	_allowed_action_cells = []
	
	for cell in used_cells:
		if cell.distance_to(origin_map_cell) <= attack_range:
			_allowed_action_cells.append(cell)
	
	host._remove_blinking_cells()
	host._add_blinking_cells(_allowed_action_cells)

#-------------------------------------------------------------------------------

func _determine_behavioral_ai_actions(host):
	"""
	Determines the type of battle actions that the current Enemy or NPC
	Battler will take based on their behavioral profile.
	"""
	if _action_list.empty():
		match _current_battler.battle_ai_behavior:
			'aggressive_melee':
				_action_list = ['move_to_attack', 'attack']
	
	_next_ai_battle_action(host)

#-------------------------------------------------------------------------------

func _determine_move_cells(host):
	"""
	Determines what cells the current Battler will be allowed to move into
	during its turn and then displays the allowable cells.
	"""
	var move_stat = _current_battler.provide_job_info()['move']
	var mover_type = ActorDatabase.lookup_type(_current_battler.reference)
	var origin_map_cell = host.world_to_map(_current_battler.position)
	var used_cells = host.provide_used_cells('map')
	host._allowed_move_cells = []
	
	for cell in used_cells:
		if cell.distance_to(origin_map_cell) <= move_stat:
			host._allowed_move_cells.append(cell)
	
	for cell in host._allowed_move_cells:
		var obstacle = host._check_obstacle(cell)
		if obstacle:
			if ActorDatabase.lookup_type(obstacle.reference) != mover_type:
				host._allowed_move_cells.erase(cell)
	
	host._remove_blinking_cells()
	host._add_blinking_cells(host._allowed_move_cells)

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

func _find_attack_target_for_ai(host):
	var battlers = host.provide_battlers()
	var targets = []
	var closest_target = {}
	var current_type = ActorDatabase.lookup_type(_current_battler.reference)
	
	# Look for Allies and NPCs if Enemy
	if current_type == 'enemy':
		for battler in battlers:
			var target_type = ActorDatabase.lookup_type(battler.reference)
			if target_type in ['ally', 'npc']:
				targets.append(battler)
	# Look for Enemies if NPC
	elif current_type == 'npc':
		for battler in battlers:
			var target_type = ActorDatabase.lookup_type(battler.reference)
			if target_type == 'enemy':
				targets.append(battler)
	
	# Find the closest target from targets list
	var origin_cell = host.world_to_map(_current_battler.position)
	for target in targets:
		var target_cell = host.world_to_map(target.position)
		var distance = origin_cell.distance_to(target_cell)
		if not closest_target:
			closest_target['target'] = target
			closest_target['distance'] = distance
		else:
			if distance < closest_target['distance']:
				closest_target['target'] = target
				closest_target['distance'] = distance
	
	_target = closest_target['target']

#-------------------------------------------------------------------------------

func _find_closest_cell_near_target(host, action):
	var action_range = 0
	var origin_cell = host.world_to_map(_current_battler.position)
	var target_cell = host.world_to_map(_target.position)
	var used_map_cells = host.provide_used_cells('map')
	var closest_cell = origin_cell
	var target_distance = origin_cell.distance_to(target_cell)
	
	match action:
		'attack':
			action_range = _current_weapon.provide_stats()['attack_range']
	
	# Search for cell that puts Battler within range of the target
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
				if not neighbor in host._allowed_move_cells:
					continue
				if neighbor in visited:
					continue
				var distance = neighbor.distance_to(target_cell)
				visited.append(neighbor)
				frontier.append([neighbor, distance])
		
		# If no cell is in range, get Battler as close to target as possible
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

func _next_ai_battle_action(host):
	if _action_list.empty():
		_current_battler.script_running = false
		setup_for_next_turn(host)
	
	var next_action = _action_list.pop_front()
	yield(get_tree().create_timer(0.50), 'timeout') # Slows the ai down
	
	match next_action:
		'attack':
			var attack_range = _current_weapon.provide_stats()['attack_range']
			var current_cell = host.world_to_map(_current_battler.position)
			var target_cell = host.world_to_map(_target.position)
			var distance = current_cell.distance_to(target_cell)
			if distance <= attack_range:
				_ai_attack_target(host)
			else:
				_next_ai_battle_action(host)
		'move_to_attack':
			_find_attack_target_for_ai(host)
			var closest_cell = _find_closest_cell_near_target(host, 'attack')
			if closest_cell == host.world_to_map(_current_battler.position):
				_next_ai_battle_action(host)
			else:
				_current_battler.scripted_state_change('move')
				host._add_astar_instance(_current_battler, closest_cell)

#-------------------------------------------------------------------------------

func _perform_next_ai_move(host):
	if _move_list.empty():
		_current_battler.deactivate()
		_next_ai_battle_action(host)
		return
	
	var direction = _move_list.pop_front()
	var origin_cell = host.world_to_map(_current_battler.position)
	var next_cell = origin_cell + direction
	if next_cell in host._allowed_move_cells:
		_current_battler.perform_scripted_move(direction, 'run')
	else:
		_next_ai_battle_action(host)

#-------------------------------------------------------------------------------

func _player_attack_target(host):
	"""
	Allows the player Battler to attack a target if the Battler's Weapon has
	enough ammo.
	"""
	var ammo = _current_weapon.provide_stats()['ammo']
	var max_ammo = _current_weapon.provide_stats()['max_ammo']
	var ammo_per_attack = _current_weapon.provide_stats()['ammo_per_attack']
	if _max_target_index > -1 and max_ammo == -1:
		_current_battler.deactivate()
		host.set_process(false)
		host.emit_signal('battle_action_completed')
		_valid_targets[_target_index].hide_battle_cursor()
		_valid_targets[_target_index].take_damage(_current_weapon)
		host.emit_signal('load_target_actor_info', 
			_valid_targets[_target_index])
	elif _max_target_index > -1 and ammo >= ammo_per_attack:
		_current_battler.deactivate()
		host.set_process(false)
		host.emit_signal('battle_action_completed')
		_current_weapon.consume_ammo()
		host.emit_signal('refresh_weapon_info')
		_valid_targets[_target_index].hide_battle_cursor()
		_valid_targets[_target_index].take_damage(_current_weapon)
		host.emit_signal('load_target_actor_info', 
			_valid_targets[_target_index])

################################################################################
# PUBLIC METHODS
################################################################################

func find_player_attack_targets(host, battlers):
	"""
	Determines attack targets for for the player's Battler.
	
	Args:
		- battlers (Array): Array of Battler objects.
	"""
	var attack_range = _current_weapon.provide_stats()['attack_range']
	var origin_map_cell = host.world_to_map(_current_battler.position)
	var attacker_type = ActorDatabase.lookup_type(_current_battler.reference)
	_valid_targets = []
	_current_action = 'attack'
	
	for battler in battlers:
		var battler_type = ActorDatabase.lookup_type(battler.reference)
		var target_map_cell = host.world_to_map(battler.position)
		var distance_to_target = origin_map_cell.distance_to(target_map_cell)
		if battler_type != attacker_type and distance_to_target <= attack_range:
			_valid_targets.append(battler)
	
	_determine_attack_cells(host)
	
	if _valid_targets.empty():
		_max_target_index = -1
	else:
		_max_target_index = _valid_targets.size() - 1
	
	_target_index = 0
	host.set_process(true)

#-------------------------------------------------------------------------------

func provide_current_battler_skills(host):
	var skills = _current_battler.provide_skills()
	host.emit_signal('current_battler_skills_acquired', skills)

#-------------------------------------------------------------------------------

func setup_for_next_turn(host):
	"""
	Preparation for the next Battler's turn. Registers the next Battler in the
	turn order and its inventory before directing the battle Camera to the 
	Battler.
	"""
	if _current_battler:
		_current_battler.deactivate()
		_current_battler = null
		_weapon1 = null
		_weapon2 = null
		_current_weapon = null
		host._remove_blinking_cells()
		host.emit_signal('hide_active_actor_gui_requested')
		host.emit_signal('hide_target_actor_gui_requested')
		host.emit_signal('hide_weapon_status_requested')
	
	if _turn_order.empty():
		_determine_turn_order(host)
		return
	
	_current_battler = _turn_order.pop_front()
	var weapons = _current_battler.provide_weapons()
	_weapon1 = weapons['weapon1']
	_weapon2 = weapons['weapon2']
	_current_weapon = _current_battler.provide_current_weapon()
	host.emit_signal('current_weapon_update_requested', _current_weapon)
	_determine_move_cells(host)
	host._battle_camera.track_actor(_current_battler)

#-------------------------------------------------------------------------------

func update_current_weapon():
	if _current_weapon == _weapon1:
		_current_weapon = _weapon2
	else:
		_current_weapon = _weapon1
	
	_current_battler.swap_weapons()

#-------------------------------------------------------------------------------

func validate_skill_for_use(host, skill):
	if skill.reference == 'reload-weapon':
		_current_battler.reload_current_weapon()
		host.emit_signal('refresh_weapon_info')
		_current_battler.deactivate()
		yield(get_tree().create_timer(0.5), 'timeout')
		host.emit_signal('battle_action_completed')
		setup_for_next_turn(host)

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_Actor_move_completed(host, actor):
	_perform_next_ai_move(host)

#-------------------------------------------------------------------------------

func _on_AStarInstance_pathing_completed(host, path):
	_move_list = path
	_perform_next_ai_move(host)

#-------------------------------------------------------------------------------

func _on_BattleCamera_tracking_added(host, actor):
	"""
	Signal response after the battle Camera focuses on the next Battler in the
	turn order. The method then requests the ActiveActor GUI and activates the
	next Battler for its battle turn. If the next Battler is an Enemy or NPC, 
	the Battleground will assume control of the non-playable Battler.
	"""
	host.emit_signal('load_active_actor_info', _current_battler)
	host.emit_signal('show_active_actor_gui_requested')
	var type = ActorDatabase.lookup_type(_current_battler.reference)
	if type in ['enemy', 'npc']:
		_current_battler.script_running = true
		_determine_behavioral_ai_actions(host)
	else:
		host.emit_signal('load_weapon_info', _weapon1, _weapon2)
		host.emit_signal('show_weapon_status_requested')
		_current_battler.activate_for_battle()
