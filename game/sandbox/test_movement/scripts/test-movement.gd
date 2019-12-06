extends Node2D

var _action_keys = {
	'W': 'move_up',
	'A': 'move_left',
	'S': 'move_down',
	'D': 'move_right'
	}

################################################################################
# VIRTUAL METHODS
################################################################################

#func _input(event):
#	var action = event.as_text()
#
#	if action in _action_keys.keys():
#
#		if Input.is_action_pressed(_action_keys[action]):
#			print(action)

func _process(delta):
	pass


func _ready():
	pass
