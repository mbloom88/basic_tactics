extends "res://assets/scripts/state.gd"

# General battle parameters
var _turn_order = []

################################################################################
# CLASSES
################################################################################

class CustomSorter:

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

func _determine_turn_order(host):
	"""
	Determines a new battle turn order for all Battlers that are registered
	on the Battleground's grid.
	"""
	_turn_order = host.provide_battlers()
	_turn_order.sort_custom(CustomSorter, 'speed_sorter')
	setup_for_next_turn(host)

################################################################################
# PUBLIC METHODS
################################################################################

func setup_for_next_turn(host):
	"""
	Preparation for the next Battler's turn. Registers the next Battler in the
	turn order and its inventory before directing the battle Camera to the 
	Battler.
	"""
	if host._current_battler:
		host.emit_signal('battle_turn_completed')
		host._current_battler.deactivate()
		host._current_battler = null
		host._current_target = null
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
		setup_for_next_turn(host)

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_BattleCamera_tracking_added(host, actor):
	"""
	Signal response after the battle Camera focuses on the next Battler in the
	turn order. The method then requests the ActiveActor GUI and activates the
	next Battler for its battle turn. If the next Battler is an Enemy or NPC, 
	the Battleground will assume control of the non-playable Battler.
	"""
	host.emit_signal('active_actor_selected', host._current_battler)
	var type = ActorDatabase.lookup_type(host._current_battler.reference)
	if type == 'ally':
		host.emit_signal('show_weapon_gui_requested', host._current_battler)
	host._current_battler.activate_for_battle()
