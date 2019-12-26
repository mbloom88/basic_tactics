"""
Base 'Actor' scene.
"""
extends KinematicBody2D

# Signals 
signal alpha_modulate_completed
signal attack_cells_requested(actor, attack_range)
signal attack_started(actor)
signal battle_action_cancelled
signal battle_actions_completed
signal battleground_info_requested(actor)
signal camera_move_requested(location, move_speed)
signal cutscene_info_requested
signal cutscene_operation_completed
signal hide_target_gui_requested
signal move_cells_requested
signal move_completed(actor)
signal move_requested(actor, direction)
signal player_menu_requested(actor)
signal reaction_completed(actor)
signal ready_for_cutscene
signal state_changed(state)
signal stats_modified
signal target_selected(target)
signal waiting
signal weapon_reloaded

# Child nodes
onready var _astar = $AStarPathfinder
onready var _job = $Job
onready var _inventory = $Inventory
onready var _tween_alpha = $TweenAlpha
onready var _tween_move = $TweenMove
onready var _cursor = $BattleCursor
onready var _skin = $Skin
onready var _reaction = $ReactionPoint/ReactionNumber
onready var _state_label = $Debug/StateLabel
onready var _weapon_label = $Debug/WeaponLabel

# State machine
var _current_state = null
var _state_stack = []

onready var _state_map = {
	'inactive': $State/Inactive,
	'idle': $State/Idle,
	'move': $State/Move,
	'menu': $State/Menu,
	'attack': $State/Attack,
	'ai': $State/AI,
}

# Actor info
export (String) var reference = "" setget , get_reference
export (bool) var onready_invisible = true

# Cutscene info
var has_cutscene_running = false setget set_has_cutscene_running, \
	get_has_cutscene_running
var _cutscene_type = ""
var _movement_type = ""


# Battle Info
export (String, 'aggressive_melee') var battle_ai_behavior = 'aggressive_melee'
var has_ai_running = false setget , get_has_ai_running
var _ai_movements = []
var _ai_target = null

################################################################################
# VIRTUAL METHODS
################################################################################

func _input(event):
	var state_name = _current_state._handle_input(self, event)
	
	if state_name:
		_change_state(state_name)

#-------------------------------------------------------------------------------

func _process(delta):
	var state_name = _current_state._update(self, delta)
	
	if state_name:
		_change_state(state_name)

#-------------------------------------------------------------------------------

func _ready():
	hide_battle_cursor()
	_weapon_label.update_label(_inventory.provide_weapons()['current'])
	_job.load_job_skills()
	_inventory.load_item_skills()
	
	if onready_invisible:
		modulate_alpha_channel('out', 'instant')
	
	_state_stack.push_front($State/Inactive)
	_current_state = _state_stack[0]
	_change_state('inactive')

################################################################################
# PRIVATE METHODS
################################################################################

func _change_state(state_name):
	if state_name != 'previous':
		if _state_map[state_name] != _current_state:
			_current_state._exit(self)

	if state_name == 'previous':
		_state_stack.pop_front()
	elif state_name in ['attack', 'move']:
		_state_stack.push_front(_state_map[state_name])
	else:
		var new_state = _state_map[state_name]
		_state_stack[0] = new_state
	
	# Set new state
	_current_state = _state_stack[0]
	
	if state_name != 'previous':
		_current_state._enter(self)
	else:
		if _current_state == _state_map['ai']:
			_current_state.next_ai_action(self)
	
	_state_label.update_label(_current_state.name)
	emit_signal("state_changed", state_name)

################################################################################
# PUBLIC METHODS
################################################################################

func activate_for_battle():
	"""
	Sets the Actor to the 'idle' state if activating an Ally. Doing so enables
	Actor input processing by the Player on the Ally. Enemy and NPC
	activations will be handled by the Actor's AI.
	"""
	if ActorDatabase.lookup_type(reference) == 'ally':
		_change_state('idle')
	elif ActorDatabase.lookup_type(reference) in ['enemy', 'npc']:
		has_ai_running = true
		_change_state('ai')

#-------------------------------------------------------------------------------

func activate_for_cutscene(type):
	has_cutscene_running = true
	_cutscene_type = type
	_change_state('ai')

#-------------------------------------------------------------------------------

func deactivate():
	"""
	Sets the Actor to the 'inactive' state. Doing so disables Actor input 
	processing.
	"""
	_change_state('inactive')

#-------------------------------------------------------------------------------

func hide_battle_cursor():
	_cursor.visible = false

#-------------------------------------------------------------------------------

func initiate_attack():
	if _current_state == _state_map['menu']:
		_change_state('attack')

#-------------------------------------------------------------------------------

func modulate_alpha_channel(fade_type, mode, speed=0.5):
	"""
	Args:
		- fade_type (String): The type of scene fade that the character will
			perform.
			* in: Character will fade into the scene.
			* out: Character will fade out of the scene.
		- mode (String): Determines whether the character will fade instantly
			of over time.
			* instant: Character fades instantly.
			* slow: Character fades slowly over a set duration.
		- speed (float): The speed at which the character fades into/from the
			scene. Ignored if mode is set to 'instant.'
	"""
	var start_alpha = modulate
	var end_alpha = modulate
	
	match [fade_type, mode]:
		['in', 'instant']:
			modulate.a = 1
			emit_signal("alpha_modulate_completed")
			return
		['out', 'instant']:
			modulate.a = 0
			emit_signal("alpha_modulate_completed")
			return
		['in', 'slow']:
			start_alpha.a = 0
			end_alpha.a = 1
		['out', 'slow']:
			start_alpha.a = 1
			end_alpha.a = 0
	
	_tween_alpha.interpolate_property(
		self,
		"modulate",
		start_alpha,
		end_alpha,
		speed,
		Tween.TRANS_LINEAR,
		Tween.EASE_IN)
	
	_tween_alpha.start()

#-------------------------------------------------------------------------------

func perform_cutscene_move(goal_cell, movement_type):
	"""
	Args:
		- goal_cell (Vector2): Map cell
		- movement_type (String): Movement can eithe be 'run' or 'walk.'
	"""
	if _current_state == _state_map['ai']:
		_movement_type = movement_type
		_current_state.setup_for_cutscene_move(self, goal_cell)

#-------------------------------------------------------------------------------

func perform_move(world_position):
	"""
	Move command that tells the Actor the next world position to move into. 
	Generally called from the 'Level/Ground' node after an Actor has made a move
	request.
	
	Args:
		- world_position (Vector2): World position for the Actor to move into.
	"""
	if _current_state == _state_map['move']:
		_current_state.move_to_position(self, world_position)

#-------------------------------------------------------------------------------

func provide_job_info():
	return _job.provide_job_info()

#-------------------------------------------------------------------------------

func provide_skills():
	return _job.provide_skills()

#-------------------------------------------------------------------------------

func provide_weapons():
	return _inventory.provide_weapons()

#-------------------------------------------------------------------------------

func reload_current_weapon():
	_inventory.reload_current_weapon()

#-------------------------------------------------------------------------------

func resume_from_player_menu():
	"""
	Commands the Actor to resume processing after exiting from the Player Menu.
	"""
	_change_state('idle')

#-------------------------------------------------------------------------------

func search_for_attack_targets(target_info):
	"""
	Args:
		target_info (Dictionary): A dictionary that holds the requesting actor
			as a key within its current map cell as a value. Targets are listed 
			as keys and their associated map cells are their values. The map
			cells can be used for determining distances.
	"""
	if _current_state == _state_map['attack']:
		_current_state.search_for_attack_targets(self, target_info)

#-------------------------------------------------------------------------------

func show_battle_cursor():
	_cursor.visible = true

#-------------------------------------------------------------------------------

func swap_weapons():
	_inventory.swap_weapons()

#-------------------------------------------------------------------------------

func take_damage(weapon):
	_job.take_damage(weapon)
	_skin.take_damage()
	_reaction.take_damage(weapon.provide_stats()['attack_damage'])

#-------------------------------------------------------------------------------

func update_ai_battleground_info(target_info):
	if _current_state == _state_map['ai']:
		_current_state.update_ai_battleground_info(self, target_info)

#-------------------------------------------------------------------------------

func update_level(value):
	_job.level = value

################################################################################
# SETTERS
################################################################################

func set_has_cutscene_running(value):
	has_cutscene_running = value

################################################################################
# GETTERS
################################################################################

func get_has_ai_running():
	return has_ai_running

#-------------------------------------------------------------------------------

func get_has_cutscene_running():
	return has_cutscene_running

#-------------------------------------------------------------------------------

func get_reference():
	return reference

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_AStarPathfinder_pathing_completed(path):
	if _current_state == _state_map['ai']:
		_current_state._on_AStarPathfinder_pathing_completed(self, path)

#-------------------------------------------------------------------------------

func _on_Inventory_current_weapon_updated(current_weapon):
	_weapon_label.update_label(current_weapon)

#-------------------------------------------------------------------------------

func _on_Inventory_new_skills_loaded(skill_refs):
	_job.load_weapon_skills(skill_refs)

#-------------------------------------------------------------------------------

func _on_Inventory_weapon_reloaded():
	emit_signal('weapon_reloaded')

#-------------------------------------------------------------------------------

func _on_Job_stats_modified():
	emit_signal('stats_modified')

#-------------------------------------------------------------------------------

func _on_Job_item_skills_requested():
	_inventory.load_item_skills()

#-------------------------------------------------------------------------------

func _on_Job_weapon_reload_requested():
	_inventory.reload_current_weapon()

#-------------------------------------------------------------------------------

func _on_ReactionNumber_animation_completed():
	emit_signal('reaction_completed', self)

#-------------------------------------------------------------------------------

func _on_TweenMove_tween_completed(object, key):
	if _current_state == _state_map['move']:
		var state_name = _current_state._on_TweenMove_tween_completed(self, \
		object, key)
		
		if state_name:
			_change_state(state_name)

#-------------------------------------------------------------------------------

func _on_TweenAlpha_tween_completed(object, key):
	emit_signal("alpha_modulate_completed")
