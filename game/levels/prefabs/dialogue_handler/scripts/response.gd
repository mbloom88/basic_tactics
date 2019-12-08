tool
extends HBoxContainer

# Child nodes
onready var _portrait = $CharacterPortrait
onready var _name = $VBoxContainer/CharacterName

export (String, 'left', 'right') var portrait_alignment = 'left' \
	setget set_portrait_alignment

################################################################################
# SETTERS
################################################################################

func set_portrait_alignment(value):
	portrait_alignment = value
	
	match value:
		'left':
			move_child(_portrait, 0)
			_name.align = Label.ALIGN_LEFT
		'right':
			var last_index = get_child_count() - 1
			move_child(_portrait, last_index)
			_name.align = Label.ALIGN_RIGHT
