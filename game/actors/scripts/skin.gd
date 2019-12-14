extends Sprite

# Signals
signal animation_finished

# Child nodes
onready var _anim = $AnimationPlayer

################################################################################
# PUBLIC METHODS
################################################################################

func take_damage():
	_anim.play('damaged')

#-------------------------------------------------------------------------------

func _on_AnimationPlayer_animation_finished(anim_name):
	emit_signal('animation_finished')
