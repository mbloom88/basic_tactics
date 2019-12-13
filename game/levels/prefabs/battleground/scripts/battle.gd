extends "res://assets/scripts/state.gd"

var _turn_order = []
var _current_battler = null
var _current_weapon = null
var _valid_targets = []
var _max_target_index = 0
var _target_index = 0

################################################################################
# CLASSES
################################################################################

class CustomSorter:
	
	static func speed_sorter(actor_a, actor_b):
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
	_check_targets()

################################################################################
# PRIVATE METHODS
################################################################################

func _check_targets():
	var action = ""
	
	if Input.is_action_just_pressed("move_left"):
		_valid_targets[_target_index].hide_battle_cursor()
		if _target_index > 0:
			_target_index -= 1
		else:
			_target_index = _max_target_index
		_valid_targets[_target_index].show_battle_cursor()
	elif Input.is_action_just_pressed("move_right"):
		_valid_targets[_target_index].hide_battle_cursor()
		if _target_index < _max_target_index:
			_target_index += 1
		else:
			_target_index = 0
		_valid_targets[_target_index].show_battle_cursor()
	elif Input.is_action_just_pressed('ui_cancel'):
		_valid_targets[_target_index].hide_battle_cursor()

#-------------------------------------------------------------------------------

func _determine_turn_order(host):
	_turn_order = host.provide_battlers()
	_turn_order.sort_custom(CustomSorter, 'speed_sorter')
	setup_for_next_turn(host)

################################################################################
# PUBLIC METHODS
################################################################################

func search_for_attack_targets(host, battlers):
	"""
	Args:
		- battlers (Array): Array of Battler objects.
	"""
	var attack_range = _current_weapon.provide_stats()['attack_range']
	for battler in battlers:
		var battler_type = ActorDatabase.lookup_type(battler.reference)
		if battler_type != _current_battler.reference:
			_valid_targets.append(battler)
	
	_max_target_index = len(_valid_targets) - 1
	_target_index = 0
	
	print(_valid_targets)
	
	host.set_process(true)

#-------------------------------------------------------------------------------

func setup_for_next_turn(host):
	if _current_battler:
		_current_battler.deactivate()
		_current_battler = null
		_current_weapon = null
	
	if _turn_order.empty():
		_determine_turn_order(host)
		return
	
	_current_battler = _turn_order.pop_front()
	_current_weapon = _current_battler.provide_weapon()
	
	# Determine allowed move cells
	var move_stat = _current_battler.provide_job_info()['move']
	var actor_type = ActorDatabase.lookup_type(_current_battler.reference)
	var current_cell = host.world_to_map(_current_battler.position)
	var used_cells = host.provide_used_cells('map')
	host._allowed_map_cells = []
	
	for cell in used_cells:
		if cell.distance_to(current_cell) <= move_stat:
			host._allowed_map_cells.append(cell)
	
	for cell in host._allowed_map_cells:
		var obstacle = host._check_obstacle(cell)
		if obstacle:
			if ActorDatabase.lookup_type(obstacle.reference) != actor_type:
				host._allowed_map_cells.erase(cell)
	
	host._add_blinking_tiles(host._allowed_map_cells)
	host._battle_camera.track_actor(_current_battler)

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_BattleCamera_tracking_added(host, actor):
	host.emit_signal('load_active_actor_info', _current_battler)
	host.emit_signal('next_actor_in_turn')
	actor.activate()
