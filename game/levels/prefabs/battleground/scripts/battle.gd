extends "res://assets/scripts/state.gd"

var _turn_order = []
var _first_turn = true
var _current_battler = null

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

################################################################################
# PRIVATE METHODS
################################################################################

func _determine_turn_order(host):
	_turn_order = host.provide_battlers()
	_turn_order.sort_custom(CustomSorter, 'speed_sorter')
	
	if _first_turn:
		_first_turn = false
		_setup_for_next_turn(host)

#-------------------------------------------------------------------------------

func _setup_for_next_turn(host):
	if _current_battler:
		_current_battler.deactivate()
	
	_current_battler = _turn_order.pop_front()
	
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
				host._allowed_map_cells.remove(cell)
	
	host._add_blinking_tiles(host._allowed_map_cells)
	host._battle_camera.track_actor(_current_battler)

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_BattleCamera_tracking_added(host, actor):
	actor.activate()
