extends NinePatchRect

# Child nodes
onready var _label = $Label

################################################################################
# VIRTUAL METHODS
################################################################################

func _ready():
	hide_gui()

################################################################################
# PUBLIC METHODS
################################################################################

func hide_gui():
	visible = false

#-------------------------------------------------------------------------------

func show_gui():
	visible = true

#-------------------------------------------------------------------------------

func update_squad_count():
	var count = PartyDatabase.allies_in_squad
	var limit = PartyDatabase.squad_limit
	_label.text = 'Squad Count: %s / %s' % [count, limit]
