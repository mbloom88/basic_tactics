extends Control

# Child nodes
onready var _active_panel = $ActiveActorPanel
onready var _squad_count = $SquadCount
onready var _squad_status = $SquadStatus

################################################################################
# VIRTUAL METHODS
################################################################################

func _ready():
	hide_ally_select_gui()

################################################################################
# PUBLIC METHODS
################################################################################

func hide_active_actor_gui():
	_active_panel.hide_gui()
	
#-------------------------------------------------------------------------------

func hide_ally_select_gui():
	_active_panel.hide_gui()
	_squad_count.hide_gui()
	_squad_status.hide_gui()

#-------------------------------------------------------------------------------

func load_actor_info(actor_ref):
	_active_panel.load_actor_info(actor_ref)

#-------------------------------------------------------------------------------

func show_active_actor_gui():
	_active_panel.show_gui()

#-------------------------------------------------------------------------------

func show_ally_select_gui():
	_active_panel.show_gui()
	_squad_count.show_gui()
	_squad_status.show_gui()

#-------------------------------------------------------------------------------

func update_squad_count():
	_squad_count.update_squad_count()

#-------------------------------------------------------------------------------

func update_squad_status(type):
	_squad_status.update_squad_status(type)
