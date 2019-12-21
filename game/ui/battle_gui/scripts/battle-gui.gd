extends Control

# Signals 
signal weapon_changed

# Child nodes
onready var _active_panel = $ActiveActorPanel
onready var _target_panel = $TargetActorPanel
onready var _squad_count = $SquadCount
onready var _squad_status = $SquadStatus
onready var _weapon_status1 = $WeaponStatus1
onready var _weapon_status2 = $WeaponStatus2
onready var _weapon_swap = $WeaponSwap

# Weapons
var _current_weapon = null
var _weapon_focus = null

################################################################################
# VIRTUAL METHODS
################################################################################

func _ready():
	_target_panel.box_alignment = 'right'
	_weapon_focus = _weapon_status1
	_weapon_status2.deactivate()

################################################################################
# PUBLIC METHODS
################################################################################

func activate_weapon_swap():
	_weapon_swap.activate()

#-------------------------------------------------------------------------------

func deactivate_weapon_swap():
	_weapon_swap.deactivate()

#-------------------------------------------------------------------------------

func hide_active_actor_gui():
	_active_panel.hide_gui()
	
#-------------------------------------------------------------------------------

func hide_ally_select_gui():
	_active_panel.hide_gui()
	_squad_count.hide_gui()
	_squad_status.hide_gui()

#-------------------------------------------------------------------------------

func hide_target_actor_gui():
	_target_panel.hide_gui()

#-------------------------------------------------------------------------------

func hide_weapon_status():
	_weapon_status1.hide_gui()
	_weapon_status2.hide_gui()
	_weapon_swap.hide_gui()

#-------------------------------------------------------------------------------

func load_weapon_info(weapon1, weapon2):
	_weapon_status1.load_weapon_info(weapon1)
	_weapon_status2.load_weapon_info(weapon2)
	
	if _current_weapon == _weapon_status1.provide_assigned_weapon():
		_weapon_status1.activate()
		_weapon_status2.deactivate()
		_weapon_focus = _weapon_status1
	elif _current_weapon == _weapon_status2.provide_assigned_weapon():
		_weapon_status1.deactivate()
		_weapon_status2.activate()
		_weapon_focus = _weapon_status2

#-------------------------------------------------------------------------------

func refresh_weapon_info():
	_weapon_status1.refresh_weapon_info()
	_weapon_status2.refresh_weapon_info()

#-------------------------------------------------------------------------------

func show_active_actor_gui(actor):
	_active_panel.load_actor_info(actor)
	_active_panel.show_gui()

#-------------------------------------------------------------------------------

func show_ally_select_gui():
	_active_panel.show_gui()
	_squad_count.show_gui()
	_squad_status.show_gui()

#-------------------------------------------------------------------------------

func show_target_actor_gui(target):
	_target_panel.load_actor_info(target)
	_target_panel.show_gui()

#-------------------------------------------------------------------------------

func show_weapon_status():
	_weapon_status1.show_gui()
	_weapon_status2.show_gui()
	_weapon_swap.show_gui()

#-------------------------------------------------------------------------------

func update_current_weapon(current_weapon):
	"""
	Args:
		- weapon (Object)
	"""
	_current_weapon = current_weapon
	
	if _weapon_focus == _weapon_status1:
		_weapon_status1.activate()
		_weapon_status2.deactivate()
		_weapon_focus = _weapon_status1
	elif _weapon_focus == _weapon_status2:
		_weapon_status1.deactivate()
		_weapon_status2.activate()
		_weapon_focus = _weapon_status2

#-------------------------------------------------------------------------------

func update_squad_count():
	_squad_count.update_squad_count()

#-------------------------------------------------------------------------------

func update_squad_status(type):
	_squad_status.update_squad_status(type)

#-------------------------------------------------------------------------------

func _on_WeaponSwap_pressed():
	_weapon_focus.deactivate()
	
	if _weapon_focus == _weapon_status1:
		_current_weapon = _weapon_status2.provide_assigned_weapon()
		_weapon_focus = _weapon_status2
	elif _weapon_focus == _weapon_status2:
		_current_weapon = _weapon_status1.provide_assigned_weapon()
		_weapon_focus = _weapon_status1

	_weapon_focus.activate()
	
	emit_signal('weapon_changed')
