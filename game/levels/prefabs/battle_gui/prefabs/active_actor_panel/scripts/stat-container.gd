extends HBoxContainer

# Child nodes:
onready var _texture = $TextureProgress
onready var _value = $ValueLabel

# Container info
export (String, 'health', 'armor', 'shields')  var type = 'health'

################################################################################
# PUBLIC METHODS
################################################################################

func update_info(stats):
	match type:
		'health':
			_texture.max_value = stats['max_health']
			_texture.value = stats['health']
			_value.text = '%s / %s' % [stats['health'], stats['max_health']]
		'armor':
			_texture.max_value = stats['max_armor']
			_texture.value = stats['armor']
			_value.text = '%s / %s' % [stats['armor'], stats['max_armor']]
		'shields':
			_texture.max_value = stats['max_shields']
			_texture.value = stats['shields']
			_value.text = '%s / %s' % [stats['shields'], stats['max_shields']]
