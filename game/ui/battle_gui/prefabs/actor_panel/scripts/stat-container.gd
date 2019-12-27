extends HBoxContainer

# Child nodes:
onready var _texture = $TextureProgress
onready var _value = $ValueLabel

# Container info
export (String, 'health')  var type = 'health'

################################################################################
# PUBLIC METHODS
################################################################################

func subtract_amount(amount):
	"""
	Args:
		- amount (int): Value to subtract from the texture progress.
	"""
	_texture.value -= amount

#-------------------------------------------------------------------------------

func update_info(stats):
	match type:
		'health':
			_texture.max_value = stats['max_health']
			_texture.value = stats['health']
			_value.text = '%s / %s' % [stats['health'], stats['max_health']]
