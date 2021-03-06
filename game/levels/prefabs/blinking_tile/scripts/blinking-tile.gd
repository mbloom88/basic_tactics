extends Sprite

# Child nodes
onready var _anim = $AnimationPlayer

################################################################################
# VIRTUAL METHODS
################################################################################

func _ready():
	stop_blinking()

################################################################################
# PUBLIC METHODS
################################################################################

func blink():
	_anim.play('blink')

#-------------------------------------------------------------------------------

func stop_blinking():
	_anim.play('stop-blinking')
