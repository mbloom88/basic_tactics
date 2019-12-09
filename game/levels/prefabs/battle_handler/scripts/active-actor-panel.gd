extends NinePatchRect

# Child nodes
onready var _portrait = $HBoxContainer/NeutralPortait

################################################################################
# PUBLIC METHODS
################################################################################

func hide_gui():
	visible = false

#-------------------------------------------------------------------------------

func load_portrait(actor_ref):
	_portrait.texture = ActorDatabase.lookup_portrait(actor_ref)

#-------------------------------------------------------------------------------

func show_gui():
	visible = true
