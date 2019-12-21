extends NinePatchRect

# Child nodes
onready var _label = $StatusLabel

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

func update_squad_status(status):
	match status:
		'in_squad':
			_label.text = 'IN SQUAD'
			_label.set("custom_colors/font_color", Color.chartreuse)
		'not_selected':
			_label.text = 'NOT IN SQUAD'
			_label.set("custom_colors/font_color", Color.red)
