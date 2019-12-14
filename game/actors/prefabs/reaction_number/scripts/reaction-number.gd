extends Label

# Signals
signal animation_completed

# Child nodes
onready var _anim = $AnimationPlayer

################################################################################
# VIRTUAL METHODS
################################################################################

func _ready():
	_anim.play('hide')

################################################################################
# PUBLIC METHODS
################################################################################

func heal(value):
	"""
	Args:
		- value (int)
	"""
	text = str(value)
	set("custom_colors/font_color", Color.chartreuse)
	_anim.play('show')

#-------------------------------------------------------------------------------

func take_damage(value):
	"""
	Args:
		- value (int)
	"""
	text = str(value)
	set("custom_colors/font_color", Color.red)
	_anim.play('show')

################################################################################
# SIGNAL HANDLING
################################################################################

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == 'show':
		emit_signal('animation_completed')
