extends Control

# Child nodes
onready var _active_panel = $ActiveActorPanel

################################################################################
# VIRTUAL METHODS
################################################################################

func _ready():
	hide_ally_select_gui()

################################################################################
# PUBLIC METHODS
################################################################################

func hide_ally_select_gui():
	_active_panel.hide_gui()

#-------------------------------------------------------------------------------

func load_actor_info(actor_ref):
	_active_panel.load_actor_info(actor_ref)

#-------------------------------------------------------------------------------

func show_ally_select_gui():
	_active_panel.show_gui()
