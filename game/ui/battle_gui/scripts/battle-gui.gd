extends Control

# Child nodes
onready var _active_panel = $ActiveActorPanel
onready var _active_anim =$ActiveActorPanel/ActiveAnimation
onready var _target_panel = $TargetActorPanel
onready var _target_anim = $TargetActorPanel/TargetAnimation
onready var _squad_count = $SquadCount
onready var _squad_status = $SquadStatus
onready var _weapon_anim = $WeaponPanel/WeaponAnimation
onready var _weapon_status1 = $WeaponPanel/HBoxContainer/WeaponStatus1
onready var _weapon_status2 = $WeaponPanel/HBoxContainer/WeaponStatus2
onready var _weapon_swap = $WeaponPanel/HBoxContainer/WeaponSwap

# Actor and Weapons
var _active_actor = null
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
	_active_anim.play('active_exit')
	
#-------------------------------------------------------------------------------

func hide_ally_select_gui():
	hide_active_actor_gui()
	_squad_count.hide_gui()
	_squad_status.hide_gui()

#-------------------------------------------------------------------------------

func hide_target_actor_gui():
	_target_anim.play('target_exit')

#-------------------------------------------------------------------------------

func hide_weapon_gui():
	_weapon_anim.play('weapon_exit')

#-------------------------------------------------------------------------------

func load_active_actor_gui(actor):
	_active_panel.load_actor(actor)
	_active_anim.play('active_enter')

#-------------------------------------------------------------------------------

func load_target_actor_gui(target):
	_target_panel.load_actor(target)
	_target_anim.play('target_enter')

#-------------------------------------------------------------------------------

func load_weapon_gui(actor):
	"""
	Loads new weapons onto the GUI before displaying the GUI.
	
	Args:
		- actor (Object): The actor that the weapons will be derived from.
	"""
	_active_actor = actor
	var weapons = actor.provide_weapons()
	_weapon_status1.load_weapon(weapons['weapon1'])
	_weapon_status2.load_weapon(weapons['weapon2'])
	_current_weapon = weapons['current']
	
	if _current_weapon == _weapon_status1.current_weapon:
		_weapon_status1.activate()
		_weapon_status2.deactivate()
		_weapon_focus = _weapon_status1
	elif _current_weapon == _weapon_status2.current_weapon:
		_weapon_status1.deactivate()
		_weapon_status2.activate()
		_weapon_focus = _weapon_status2
	
	activate_weapon_swap()
	show_weapon_gui()

#-------------------------------------------------------------------------------

func show_ally_select_gui():
	_active_anim.play('active_enter')
	_squad_count.show_gui()
	_squad_status.show_gui()

#-------------------------------------------------------------------------------

func show_weapon_gui():
	_weapon_anim.play('weapon_enter')

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
		_current_weapon = _weapon_status2.current_weapon
		_weapon_focus = _weapon_status2
	elif _weapon_focus == _weapon_status2:
		_current_weapon = _weapon_status1.current_weapon
		_weapon_focus = _weapon_status1

	_weapon_focus.activate()
	_active_actor.swap_weapons()
